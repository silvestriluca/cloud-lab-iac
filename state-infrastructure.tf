module "s3_remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

  dynamodb_table_name            = "tf-rstate-lock-bl-${terraform.workspace}"
  s3_bucket_force_destroy        = true
  state_bucket_prefix            = "tf-rstate-bl-${terraform.workspace}"
  replica_bucket_prefix          = "tf-rstate-replica-bl-${terraform.workspace}"
  noncurrent_version_expiration  = null
  noncurrent_version_transitions = []

  terraform_iam_policy_name_prefix = "tf-bl-${terraform.workspace}"
  iam_policy_attachment_name       = "tf-iam-role-attachment-repl-configuration-bl-${terraform.workspace}"
  iam_policy_name_prefix           = "tf-rstate-repl-policy-bl-${terraform.workspace}"
  iam_role_name_prefix             = "tf-rstate-repl-role-bl-${terraform.workspace}"

  kms_key_description = "The key used to encrypt the remote state bucket - bl-${terraform.workspace}."

  tags = local.global_tags
}
