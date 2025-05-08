
# Rule to check if RDS instance has encryption enabled
 
deny[msg] {
 
input.resource.type == "aws_rds_instance"
 
not input.resource.encrypted
 
msg = "RDS instance is not encrypted."
 
}
 
