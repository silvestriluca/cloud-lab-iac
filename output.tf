output "account-id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS acoount where infrastructure is deployed"
}

output "tf-workspace" {
  value       = terraform.workspace
  description = "TF workspace where state is persisted"
}

output "state-bucket-name" {
  value       = module.s3_remote_state.state_bucket.bucket
  description = "The S3 bucket name to store the remote state file"
}

output "state-bucket-replica-name" {
  value       = module.s3_remote_state.replica_bucket.bucket
  description = "The S3 bucket name to replicate the state S3 bucket"
}

output "state-bucket-kms-id" {
  value       = module.s3_remote_state.kms_key.id
  description = "The KMS customer master key ID to encrypt state buckets"
}
