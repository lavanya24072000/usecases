output "api_url" {
  description = "API Gateway Invoke URL"
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}/hello"
}
 
output "cognito_login_url" {
value = "https://${aws_cognito_user_pool_client.user_pool_client.user_pool_id}.auth.${var.region}.amazoncognito.com/login"
}
