
package terraform.module

deny contains msg if {
    some r
    resource_type := resources[r].type
    resource_type == "aws_s3_bucket"
    public_access := resources[r].values.public_access_block_configuration
    public_access == null or public_access.block_public_acls == false or public_access.block_public_policy == false
    msg := sprintf("S3 bucket should not have public access enabled. Resource in violation: %v", [r.address])
}
