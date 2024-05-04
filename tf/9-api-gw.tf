resource "aws_api_gateway_rest_api" "gw-api" {
  name        = var.api_gw_name
  description = "tf-cluster API with Cognito Authentication"
}

# Resource: /check
resource "aws_api_gateway_resource" "check_resource" {
  parent_id   = aws_api_gateway_rest_api.gw-api.root_resource_id
  path_part   = "check"
  rest_api_id = aws_api_gateway_rest_api.gw-api.id
}


# 4 components: Method request, Integration request, Integration response, Method response
# Method Request: GET
resource "aws_api_gateway_method" "check_method" {
  authorization = "COGNITO_USER_POOLS"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.check_resource.id
  rest_api_id   = aws_api_gateway_rest_api.gw-api.id
  authorizer_id = aws_api_gateway_authorizer.test_auth.id
}

# Integration Request
resource "aws_api_gateway_integration" "lambda_integration" {
  http_method             = aws_api_gateway_method.check_method.http_method
  resource_id             = aws_api_gateway_resource.check_resource.id
  rest_api_id             = aws_api_gateway_rest_api.gw-api.id
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

# Method Response: bind auth to /check
resource "aws_api_gateway_method_response" "check_auth" {
  http_method = aws_api_gateway_method.check_method.http_method
  resource_id = aws_api_gateway_resource.check_resource.id
  rest_api_id = aws_api_gateway_rest_api.gw-api.id
  status_code = "200"

  //cors section
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration Response
resource "aws_api_gateway_integration_response" "integration_response" {
  http_method = aws_api_gateway_method.check_method.http_method
  resource_id = aws_api_gateway_resource.check_resource.id
  rest_api_id = aws_api_gateway_rest_api.gw-api.id
  status_code = aws_api_gateway_method_response.check_auth.status_code

  //cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_method.check_method, aws_api_gateway_integration.lambda_integration]
}

# authorizer
resource "aws_api_gateway_authorizer" "test_auth" {
  name          = "TestAuth"
  rest_api_id   = aws_api_gateway_rest_api.gw-api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.cognito-pool.arn]
}


# stage deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.gw-api.id
  stage_name  = "dev"

    depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}