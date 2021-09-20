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

## CodeBuild "God mode"
By default, Codebuild has a role with no policies attached.
To provide Codebuild with Admin capabilities you have to have admin role in the target AWS account.
Once you have Admin capabilities, do what follows:
1. Go to repo root directory
2. `mkdir private/scripts`
3. `cp templates/scripts/* private/scripts`
4. Collect the names of CodeBuild roles you want to empower with Admin rights.
5. Edit the scripts `private/scripts/god.sh` & `private/scripts/ungod.sh` 

Now you can use the scripts in the repo directory:
- `godpush.sh` => Push an updated version of your infrastructure and activates "God mode"
- `ungod.sh` => Deactivates God mode on all CodeBuild roles you specified in point 5.

## License
See [License file](./LICENSE)
