locals {
  state_locking_table = "tf-rstate-lock-${var.app_name_prefix}-${terraform.workspace}"
}


module "s3_remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

  dynamodb_table_name            = local.state_locking_table
  s3_bucket_force_destroy        = true
  state_bucket_prefix            = "tf-rstate-${var.app_name_prefix}-${terraform.workspace}-"
  replica_bucket_prefix          = "tf-rstate-replica-${var.app_name_prefix}-${terraform.workspace}-"
  noncurrent_version_expiration  = null
  noncurrent_version_transitions = []

  terraform_iam_policy_name_prefix = "tf-${var.app_name_prefix}-${terraform.workspace}-"
  iam_policy_attachment_name       = "tf-iam-role-attachment-repl-configuration-${var.app_name_prefix}-${terraform.workspace}-"
  iam_policy_name_prefix           = "tf-rstate-repl-policy-${var.app_name_prefix}-${terraform.workspace}-"
  iam_role_name_prefix             = "tf-rstate-repl-role-${var.app_name_prefix}-${terraform.workspace}-"

  kms_key_description = "The key used to encrypt the remote state bucket / ${var.app_name_prefix}-${terraform.workspace}."

  tags = local.global_tags
}

############# KMS #############
resource "aws_kms_alias" "state_bucket_key" {
  name          = "alias/bucket-tf-rstate-${var.app_name_prefix}-${terraform.workspace}"
  target_key_id = module.s3_remote_state.kms_key.id
}

############# SSM PARAMETER STORE #############
resource "aws_ssm_parameter" "state_bucket" {
  name      = "/${var.app_name_verbose}/${terraform.workspace}/state-bucket-name"
  value     = module.s3_remote_state.state_bucket.bucket
  type      = "SecureString"
  overwrite = true
  tags      = local.global_tags
}

resource "aws_ssm_parameter" "state_bucket_replica" {
  name      = "/${var.app_name_verbose}/${terraform.workspace}/state-bucket-replica-name"
  value     = module.s3_remote_state.replica_bucket.bucket
  type      = "SecureString"
  overwrite = true
  tags      = local.global_tags
}

resource "aws_ssm_parameter" "state_bucket_kms_id" {
  name      = "/${var.app_name_verbose}/${terraform.workspace}/state-bucket-kms-id"
  value     = module.s3_remote_state.kms_key.id
  type      = "SecureString"
  overwrite = true
  tags      = local.global_tags
}

resource "aws_ssm_parameter" "tf_backend_config" {
  name      = "/${var.app_name_verbose}/${terraform.workspace}/tf-backend-config"
  value     = <<-EOT
    bucket          = "${module.s3_remote_state.state_bucket.bucket}"
    key             = "${var.app_name_verbose}-terraform.tfstate"
    region          = "${data.aws_region.current.name}"
    encrypt         = true
    kms_key_id      = "${module.s3_remote_state.kms_key.id}"
    dynamodb_table  = "${local.state_locking_table}"
    EOT
  type      = "SecureString"
  overwrite = true
  tags      = local.global_tags
}

