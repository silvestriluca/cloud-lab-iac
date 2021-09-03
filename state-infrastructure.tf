module "s3_remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

  dynamodb_table_name            = "tf-rstate-lock-baseline"
  s3_bucket_force_destroy        = true
  state_bucket_prefix            = "tf-rstate-baseline"
  replica_bucket_prefix          = "tf-rstate-replica-baseline"
  noncurrent_version_expiration  = null
  noncurrent_version_transitions = []

  terraform_iam_policy_name_prefix = "tf-baseline"
  iam_policy_attachment_name       = "tf-iam-role-attachment-repl-configuration-baseline"
  iam_policy_name_prefix           = "tf-rstate-repl-policy-baseline"
  iam_role_name_prefix             = "tf-rstate-repl-role-baseline"

  kms_key_description = "The key used to encrypt the remote state bucket - baseline."
}
