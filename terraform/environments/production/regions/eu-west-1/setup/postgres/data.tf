data "aws_kms_key" "ebs_kms_key" {
  key_id = "alias/aws/rds"
}