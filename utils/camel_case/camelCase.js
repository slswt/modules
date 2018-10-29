const argv = require('minimist')(process.argv.slice(2));
const camelCase = require('lodash/camelCase');
const { value } = argv;

process.stdout.write(
  JSON.stringify(
    {
      value: camelCase(value),
    },
    null,
    2
  )
);
