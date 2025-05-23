output "cognito_login_url" {
value = "https://${aws_cognito_user_pool_client.user_pool_client.user_pool_id}.auth.${var.region}.amazoncognito.com/login"
}
