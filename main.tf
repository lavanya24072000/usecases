module "iam" {
    source = "./modules/iam"
    role_name = "lambda_exec_role"
}

module "lambda" {
    source = "./modules/lambda"
    function_name = "helloworldtest"
    image_uri  = "144317819575.dkr.ecr.eu-west-1.amazonaws.com/first"
    role_arn = module.iam.role_arn
}

module "apigateway" {
    source = "./modules/api_gateway"
    api_name = "hellowrold-test"
    route_key = "GET /hello"
    lambda_invoke_arn = module.lambda.invoke_arn
    lambda_arn = module.lambda.arn

}
