locals {
  is_remote      = replace(file("backend.tf"), "s3", "") != file("backend.tf")
  state_location = local.is_remote ? "remote" : "local"
}
