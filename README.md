fghjghjklncvbn
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | ./modules/rds | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |
| <a name="module_web_server_1"></a> [web\_server\_1](#module\_web\_server\_1) | ./modules/web_server | n/a |
| <a name="module_web_server_2"></a> [web\_server\_2](#module\_web\_server\_2) | ./modules/web_server | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for EC2 instance-01 | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Database password | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database username | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | n/a |
| <a name="output_web_server_1_public_ip"></a> [web\_server\_1\_public\_ip](#output\_web\_server\_1\_public\_ip) | n/a |
| <a name="output_web_server_2_public_ip"></a> [web\_server\_2\_public\_ip](#output\_web\_server\_2\_public\_ip) | n/a |
<!-- END_TF_DOCS -->
rfghjhjks
