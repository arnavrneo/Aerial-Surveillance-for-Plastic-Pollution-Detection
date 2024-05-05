# create cognito
resource "aws_cognito_user_pool" "cognito-pool" {
  name = var.cognito_name

  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length = 8
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK" # CONFIRM_WITH_CODE -> sends code to email
    email_subject        = "Account confirmation"
    email_message        = "Your confirmation code is {####}"
  }

  schema {
    attribute_data_type      = "String"
    name                     = "email"
    developer_only_attribute = false
    required                 = true
    mutable                  = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "cognito-client" {
  name                                 = var.cognito_client_name
  allowed_oauth_flows_user_pool_client = true
  user_pool_id                         = aws_cognito_user_pool.cognito-pool.id
  generate_secret                      = true
  refresh_token_validity               = 90
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_scopes                 = ["aws.cognito.signin.user.admin", "email", "openid", "profile"]
  allowed_oauth_flows                  = ["implicit"]
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  callback_urls = ["https://examples.com/callback"]
  logout_urls   = ["https://examples.com/logout"]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = "<DOMAIN_NAME_HERE>"
  user_pool_id = aws_cognito_user_pool.cognito-pool.id
}

resource "aws_cognito_user" "user1" {
  user_pool_id = aws_cognito_user_pool.cognito-pool.id
  username     = "test"
  password     = "12345678"

  attributes = {
    email          = "<ENTER_MAIL_HERE>"
    email_verified = true
  }
}