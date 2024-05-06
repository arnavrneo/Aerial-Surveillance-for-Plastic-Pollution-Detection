data "archive_file" "lambda_package" {
  output_path = "index.zip"
  source_file = "index.js"
  type        = "zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name    = "check"
  role             = aws_iam_role.lambda_role.arn
  filename         = "index.zip"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "lambda_role"
}

# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["apigateway:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = data.aws_iam_policy_document.example.json
}

# resource "aws_iam_policy" "lambda_policy" {
#   name = "lambda-policy"
#   policy = jsonencode({
#   	"Version": "2012-10-17",
# 	"Statement": [
# 		{
# 			"Action": [
# 				"apigateway:GET",
# 				"apigateway:PATCH",
# 				"apigateway:POST",
# 				"apigateway:PUT",
# 				"apigateway:DELETE"
# 			],
# 			"Effect": "Allow",
# 			"Resource": aws_api_gateway_rest_api.gw-api.execution_arn
# 		}
# 	]
# })
# }


resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.gw-api.execution_arn}/*/*"
}