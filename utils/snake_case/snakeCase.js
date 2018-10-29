const argv = require('minimist')(process.argv.slice(2));
const snakeCase = require('lodash/snakeCase');
const { value } = argv;

process.stdout.write(
  JSON.stringify(
    {
      value: snakeCase(value),
    },
    null,
    2
  )
);
