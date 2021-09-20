####### VARIABLES #######
variable "app_name_prefix" {
  type        = string
  description = "Name of the app/service to which the infrastructure refers to. Prefix (short) version"
}
variable "app_name_verbose" {
  type        = string
  description = "Name of the app/service to which the infrastructure refers to. Verbose version"
}

variable "repo_branches" {
  type        = list(string)
  description = "List of branches that require CI/CD infrastructure"
}

variable "repo_id" {
  type        = string
  description = "Repository ID (organization/repo-name). Defaults to cloud-lab-iac original repo"
  default     = "silvestriluca/cloud-lab-iac"
}
