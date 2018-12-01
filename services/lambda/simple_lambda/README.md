### Usage
```hcl
module "lambda" {
  source = "github.com/slswt/modules//services/lambda/simple_lambda"
  service = "./service.js"
  id = "some_lambda"
}
output {
  # if service.js contains export const test = () => ...
  arn = "${lookup(module.lambda.lambda_arn, "test")}"
}
```


### Getting the resource
```javascript
// if service.js contains export const test = () => ...
const testResourceName = slswtResource('services/ms1', 'aws_lambda', 'some_lambda', {
  entry: 'test',
});
```
