####### VARIABLES #######
variable "app_name_prefix" {
  type        = string
  description = "Name of the app/service to which the infrastructure refers to. Prefix (short) version"
}
variable "app_name_verbose" {
  type        = string
  description = "Name of the app/service to which the infrastructure refers to. Verbose version"
}
