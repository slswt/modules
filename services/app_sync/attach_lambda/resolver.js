const argv = require('minimist')(process.argv.slice(2));
const camelCase = require('lodash/camelCase');
const fs = require('fs');
const path = require('path');
const { ApiId, fields: fieldsJsonString, DataSourceName } = argv;

fs.writeFileSync(path.join(__dirname, 'debug.json'), JSON.stringify(argv, null, 2));

const fields = JSON.parse(fieldsJsonString);

const capitalize = (s) => s.replace(/^.{1}/, (match) => match.toUpperCase());

const requestMappingTemplate = (fieldName) => `
{
  "version" : "2017-02-28",
  "operation": "Invoke",
  "payload": {
    "field": "${fieldName}",
    "headers": $util.toJson($context.request.headers),
    "args": $util.toJson($context.args),
    "identity": $util.toJson($context.identity)
  }
}
`;

const Resources = fields.reduce(
  (current, { value: FieldName, type: TypeName }) => ({
    ...current,
    [capitalize(camelCase(FieldName))]: {
      Type: 'AWS::AppSync::Resolver',
      Properties: {
        ApiId,
        TypeName,
        FieldName,
        DataSourceName,
        RequestMappingTemplate: requestMappingTemplate(FieldName),
        ResponseMappingTemplate: '$util.toJson($ctx.result)',
      },
    },
  }), {},
);

const stringResponse = JSON.stringify(
  {
    stack_name: `as-resolver-stack-${DataSourceName}`,
    cloud_formation_stack: JSON.stringify({
      Resources,
    }, null, 2),
  },
  null,
  2
);

process.stdout.write(stringResponse);
