####### ROUTE 53 #######

# Resource gets created only when hosted zone is different from default
resource "aws_route53_zone" "lab" {
  count = terraform.workspace == "default" ? (var.dns_hosted_zone != "mylab.example.com" ? 1 : 0) : 0
  name  = var.dns_hosted_zone

  tags = local.global_tags
}

####### PARAMETER STORE #######
resource "aws_ssm_parameter" "lab_subdomain" {
  count     = terraform.workspace == "default" ? 1 : 0
  name      = "/${var.app_name_verbose}/${terraform.workspace}/lab-subdomain"
  value     = var.dns_hosted_zone
  type      = "SecureString"
  overwrite = true
  tags      = local.global_tags
}
