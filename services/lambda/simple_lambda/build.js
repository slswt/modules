const argv = require('minimist')(process.argv.slice(2));
const AdmZip = require('adm-zip');
const fs = require('fs-extra');
const MemoryFs = require('memory-fs');
const snakeCase = require('lodash/snakeCase');
const webpack = require('webpack');
const { join } = require('path');
const pkgDir = require('pkg-dir');
const makeWebpackConfig = require('./webpack.config');
const stdinBuffer = fs.readFileSync(0); // STDIN_FILENO = 0
const removeDevDeps = require('./removeDevDeps');
const {
  rootPath,
  servicePath,
  webpackMode,
  environment,
  path,
  functionName,
  nodeExternalsWhitelist,
} = argv;

const buildDir = join(rootPath, '.webpack');
const projectRoot = pkgDir.sync(rootPath);
const webpackEntry = join(path, servicePath);
const debugFile = join(buildDir, 'debug.json');
const zipFile = join(buildDir, 'service.zip');
const outputFile = join(buildDir, 'output.json');

const input = JSON.parse(stdinBuffer);
fs.ensureDirSync(buildDir);

fs.writeFileSync(
  join(buildDir, 'input.json'),
  JSON.stringify(
    {
      rootPath,
      servicePath,
      webpackMode,
      environment,
      path,
      functionName,
    },
    null,
    2
  )
);

const result = {
  ...input,
  hasErrors: 'nope',
  buildDir,
  zipFile,
};
fs.writeFileSync(debugFile, 'No errors');

const handleError = (err) => {
  fs.writeFileSync(debugFile, err);
  result.hasErrors = 'There were some build errors, check the .webpack folder';
  console.log(JSON.stringify(result, null, 2));
};

let whitelist = null;

{
  /* handle whitelist */
  try {
    whitelist = JSON.parse(nodeExternalsWhitelist);
  } catch (err) {
    handleError(err);
  }

  if (!whitelist) {
    process.exit(1);
  }

  if (!Array.isArray(whitelist)) {
    handleError('whitelist is not an array! ' + JSON.stringify(whitelist, null, 2));
    process.exit(1);
  }
}


try {
  build();
} catch (err) {
  handleError(err);
}

function build() {
  const tmpFs = new MemoryFs();
  const compilerGetDeps = webpack(
    makeWebpackConfig({
      entry: webpackEntry,
      mode: webpackMode,
      projectRoot,
      bundleDeps: true,
      whitelist,
    })
  );
  compilerGetDeps.outputFileSystem = tmpFs;

  const memFs = new MemoryFs();
  const compiler = webpack(
    makeWebpackConfig({
      entry: webpackEntry,
      mode: webpackMode,
      projectRoot,
      bundleDeps: false,
    })
  );
  compiler.outputFileSystem = memFs;

  const getHash = (fname) => fname.match(/^(\w|\d)+\./)[0].slice(0, -1);

  const runCompiler = (comp, id) =>
    new Promise((resolve) => {
      comp.run((err, stats) => {
        resolve({ err, stats, id });
      });
    });

  Promise.all([
    runCompiler(compiler, 'noDeps'),
    runCompiler(compilerGetDeps, 'analyzeDeps'),
  ])
    .then((compiledResult) => {
      compiledResult.forEach(({ err, stats, id }) => {
        const statsFile = join(buildDir, `${id}_webpack_stats.json`);
        const cliOutputFile = join(buildDir, `${id}_webpack_output.log`);
        const errFile = join(buildDir, `${id}_webpack_errors.json`);
        const jsonStats = stats.toJson();
        if (err || stats.hasErrors()) {
          fs.writeFileSync(errFile, err);
          result.hasErrors += `There were some errors, please check ${errFile} and ${statsFile}\n`;
        }
        fs.writeFileSync(statsFile, JSON.stringify(jsonStats, null, 2));
        fs.writeFileSync(cliOutputFile, stats);
      });

      return Promise.resolve(
        compiledResult.find(({ id }) => id === 'analyzeDeps')
      );
    })
    .then(({ stats }) => {
      /* The stats correpond to analyzeDeps, but the saved file is form noDeps */
      const jsonStats = stats.toJson();
      const compiledFileName = Object.keys(memFs.data)[0];
      /* just the hash of the written code, not taking node_modules into account */
      result.fileHash = getHash(compiledFileName);
      /* this takes the node_modules into accout */
      result.completeHash = getHash(Object.keys(tmpFs.data)[0]);

      const usedDependencies = [
        ...new Set(
          jsonStats.modules
            .map(({ name }) => name)
            .filter(
              (name) => !name.match(/^external/) && name.match(/node_modules/)
            )
            .map((name) => {
              const modulePathing = name.split('node_modules/')[1];
              const moduleName = modulePathing.split('/')[0];
              return moduleName;
            })
        ),
      ].filter((name) => name !== 'aws-sdk');

      const zip = new AdmZip();
      // add file directly
      zip.addFile('service.js', memFs.data[compiledFileName]);
      fs.writeFileSync(
        join(buildDir, 'service.js'),
        memFs.data[compiledFileName]
      );

      const deps = removeDevDeps({
        projectRoot,
        usedDependencies,
      });
      deps.forEach((dep) => {
        zip.addLocalFolder(
          join(projectRoot, 'node_modules', dep),
          `node_modules/${dep}`
        );
      });
      const packageJson = JSON.parse(
        fs.readFileSync(join(projectRoot, 'package.json'), 'utf-8')
      );
      const pkgDependencies = deps.reduce(
        (ob, dep) => ({
          ...ob,
          [dep]: packageJson[dep],
        }),
        {}
      );
      zip.addFile(
        'package.json',
        JSON.stringify(
          {
            name: snakeCase(functionName),
            version: '1.0.0',
            description: 'Packaged externals for the simple_lambda',
            private: true,
            scripts: {},
            dependencies: pkgDependencies,
          },
          null,
          2
        )
      );

      // write everything to disk
      zip.writeZip(zipFile);

      const stringResponse = JSON.stringify(result, null, 2);
      fs.writeFileSync(outputFile, stringResponse);
      process.stdout.write(stringResponse);
    })
    .catch((err) => {
      handleError(err);
    });
}
