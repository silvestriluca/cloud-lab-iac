# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Automated state location awarness
- CI/CD pipeline in AWS (triggered by Githib events)
- S3 bucket for CI/CD artifacti
- IAM roles & policies for CodePipeline & CodeBuild
- God mode for Codebuild triggered by developer with admin privileges

### Changed
- Substituted variables for app in prefix/verbose context

## [0.2.0] - 2021-09-10
### Added
- S3 buckets for state files
- DynamoDB table for state locking
- IAM policies
- Basic tagging structure
- TF outputs
- SSM Parameter store entries for remote state infrastructure
- Remote state support
- Management scripts

## [0.1.0] - 2021-09-03
### Added
- Initial commit (for Gitversion)

### Changed
- N/A

### Removed
- N/A
