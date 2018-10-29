const fs = require('fs');
const { join } = require('path');
const lockfile = require('@yarnpkg/lockfile');
const eol = require('eol');
const intersection = require('lodash/intersection');

module.exports = ({ projectRoot, usedDependencies }) => {
  const packageJsonString = fs.readFileSync(
    join(projectRoot, 'package.json'),
    'utf-8'
  );
  const { dependencies: pkgDeps } = JSON.parse(packageJsonString);
  const yarnLock = fs.readFileSync(join(projectRoot, 'yarn.lock'), 'utf-8');

  const yarnLockNormalized = eol.lf(yarnLock);
  const yarnObject = lockfile.parse(yarnLockNormalized).object;

  const acceptableDeps = [];

  const addDepsToAcceptableDeps = (deps) => Object.entries(deps)
    .map(([key, val]) => ({ dep: `${key}@${val}`, key }))
    .forEach(({ dep, key }) => {
      const m = yarnObject[dep];
      if (m) {
        acceptableDeps.push(key);
      }
      if (m && m.dependencies) {
        addDepsToAcceptableDeps(m.dependencies);
      }
    });
  addDepsToAcceptableDeps(pkgDeps);
  const uniqueAcceptableModules = [...new Set(acceptableDeps)];

  const usedWithoutDevDeps = intersection(usedDependencies, uniqueAcceptableModules);

  return usedWithoutDevDeps;
};
