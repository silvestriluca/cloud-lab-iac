/*
resource "aws_iam_role" "baseline_iac_manager" {
  name_prefix        = "${app_name_verbose}_iac_manager"
  description        = "Role to manage baseline infrastructure with Terraform"
  assume_role_policy = ""
  tags               = local.global_tags
}

resource "aws_iam_role_policy_attachment" "name" {
  role       = aws_iam_role.baseline_iac_manager.name
  policy_arn = module.s3_remote_state.terraform_iam_policy.arn
}
*/
