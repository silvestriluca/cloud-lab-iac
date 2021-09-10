# cloud-lab-iac
A basic infrastructure for a cloud based lab

## Requirements
- Terraform > 1.0
- Jq
- AWS cli

## First time install
1. Clone repository
2. First time install: `./seeding.sh`
3. Migrate to S3 based remote state: `./restore-remote-state`

## Reinstall / migration to other machine
1. Clone repository
2. Restore S3 based remote state: `./restore-remote-state`

## Uninstall
- `terraform destroy`