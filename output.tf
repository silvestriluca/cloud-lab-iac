output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "tf-workspace" {
  value = terraform.workspace
}
