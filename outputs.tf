output "web_server_1_public_ip" {
  value = module.web_server_1.public_ip
}

output "web_server_2_public_ip" {
  value = module.web_server_2.public_ip
}

output "rds_endpoint" {
  value = module.rds.endpoint
}
