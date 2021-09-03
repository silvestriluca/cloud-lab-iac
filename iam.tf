resource "aws_iam_user" "base_infrastructure_terraform_user" {
  name = "TerraformBaseInfra"
}

resource "aws_iam_user_policy_attachment" "remote_state_access" {
  user = aws_iam_user.base_infrastructure_terraform_user.name
  policy_arn = module.s3_remote_state.terraform_iam_policy.arn
}