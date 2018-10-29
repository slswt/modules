const nodeExternals = require('webpack-node-externals');
const path = require('path');

module.exports = ({
  entry, mode = 'production', projectRoot, bundleDeps, whitelist = []
}) => {
  const externals = !bundleDeps
    ? [
      nodeExternals({
        /* background-tasks, friend-requests are es2015 modules which can be tree shaked and transpiled */
        /* cognito-to-voximplant-id is just small, bundle it (and errors when trying to add as it is bitbucket version) */
        modulesDir: path.join(projectRoot, 'node_modules'),
        whitelist: [],
      }),
    ]
    : [];
  const base = require(path.join(projectRoot, 'webpack.config.js'));
  return {
    ...base,
    entry,
    externals,
    mode,
  };
};
