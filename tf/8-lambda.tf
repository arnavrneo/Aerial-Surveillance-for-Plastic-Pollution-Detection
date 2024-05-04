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
  name = "lambda_role"
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
    actions = ["apigateway:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
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

# https://www.examples.com/callback#
# id_token=eyJraWQiOiJ3MjdqSDFMRktoQlV3U3k5Y01NSW1XYnhkQXAyaXFxd1EzYXp4MjdvMVwvUT0iLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoidmV3ZHFVWE03SUlwc3E3NDB3S2V3dyIsInN1YiI6IjE0MDg1NGQ4LWEwNDEtNzA0NS01YjI1LTU5MzI1NmRiMTY4MyIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV9DNk5zUmNOOW4iLCJjb2duaXRvOnVzZXJuYW1lIjoidGVzdCIsImF1ZCI6IjRtczVtZzhycm9la2pxcjJhMDQycXBrbHJuIiwiZXZlbnRfaWQiOiJlZmQ2NzY4NC02OGZiLTQ0Y2UtYWIwNC05OWM0YjlhNGFjMDIiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTcxNDgwOTE2OCwiZXhwIjoxNzE0ODEyNzY4LCJpYXQiOjE3MTQ4MDkxNjgsImp0aSI6IjcwYTdkMGM3LTg1ODgtNDczMC05NWE5LTE0M2QzYTdjODQyOSIsImVtYWlsIjoibG9wZXpoYXJyeTA5NkBnbWFpbC5jb20ifQ.PlUQ9B9pFMwyGX467rJsPi0ZgcCgNVHqdi2arPTc2mBmOKgffwWE6i09nyuojb6Rw1kf6InhSTvfUZTOCh8-tXGcPz0hMOvUfJWCLhOyvVN1olI7URFp0zhTPBb8739Non-D1f1y2kbDmZgsaXsIBpKtw9xK4XdA6t00PgPZWgX2oTfP2QEgeH5eOxxT6gi95cO5XHy8aE-6BQ-pGse_bhJ4MFR4zndxos6mdEY3ZQKmIIRH2S3FhnulLyqoZW1lFTXllhBcmzyqc6g1sFyYfFxndhGm7-jm0zL12DngZgm_NFFWcdnELGW47MDHJECwT0C5CofDDSxorZbSdIzrgA
# &access_token=eyJraWQiOiJ2aGw3UGt5aVArXC8xQmRSRnBnbitoeDRzbFZvTW9HV2l3UkVYeEV0dzAwOD0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxNDA4NTRkOC1hMDQxLTcwNDUtNWIyNS01OTMyNTZkYjE2ODMiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV9DNk5zUmNOOW4iLCJ2ZXJzaW9uIjoyLCJjbGllbnRfaWQiOiI0bXM1bWc4cnJvZWtqcXIyYTA0MnFwa2xybiIsImV2ZW50X2lkIjoiZWZkNjc2ODQtNjhmYi00NGNlLWFiMDQtOTljNGI5YTRhYzAyIiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiBvcGVuaWQgcHJvZmlsZSBlbWFpbCIsImF1dGhfdGltZSI6MTcxNDgwOTE2OCwiZXhwIjoxNzE0ODEyNzY4LCJpYXQiOjE3MTQ4MDkxNjgsImp0aSI6IjgxNDU3NTgwLTA5ZDctNGI5MS1hNmZmLTYyZTA2MzgyODY4NSIsInVzZXJuYW1lIjoidGVzdCJ9.Mb5MD235UR--WcbNLAasY6D0j-d0H30K6weo17mQ-zmg8HVHLgDd8RMkqfIAc-rgvCyrAH8KijK0cp9YoH6URGXM-x_d27WdkXkWQAfp6o2YGXiLyqCfh_1FVC5eHXaYB9rK2ipKnm5ROuAGrHWEOSlqkbzYmvmYsqyz7WU6eGge-2aZf-qjLTG6MM2B32VfGpLKJR2na0bI0Hgl3dnBlu-di93AIw0Mn2pZz22rB7eZ3v4q4yO6BRCYog41-JEAJVcWEvPUlD3EIpx7pyfzqTtZbmeMoqxWDTh6B2kT1c6LeWGbNst-Ow-Z_M_1-yJEXbg3Yve6PVqGKndzfihc_g
# &expires_in=3600&token_type=Bearer
