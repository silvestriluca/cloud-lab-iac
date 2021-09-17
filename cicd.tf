################## IAM POLICIES/ROLES ##################

resource "aws_iam_role" "codepipeline_role" {
  name_prefix = "codepipeline-role-${var.app_name_prefix}-${terraform.workspace}-"
  description = "Role for ${var.app_name_verbose}-${terraform.workspace} Pipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.global_tags
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name_prefix = "codepipeline-policy-${var.app_name_prefix}-${terraform.workspace}-"
  role        = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.source_repo.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix = "codebuild-role-${var.app_name_prefix}-${terraform.workspace}-"
  description = "Role for ${var.app_name_verbose}-${terraform.workspace} Codebuild projects"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = local.global_tags
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name_prefix = "codebuild-policy-${var.app_name_prefix}-${terraform.workspace}-"
  role        = aws_iam_role.codebuild_role.name


  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "${aws_ssm_parameter.terraform_version.arn}"
      ]
    }
  ]
}
EOF
}

################## S3 (Artifact store) ##################

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = "${var.app_name_prefix}-cicd-artifacts-${terraform.workspace}-"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = local.global_tags
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################## SSM - PARAMETER STORE ##################

resource "aws_ssm_parameter" "repo_id" {
  name      = "/${var.app_name_verbose}/${terraform.workspace}/repo-id"
  value     = var.repo_id
  type      = "SecureString"
  overwrite = true
  tags      = local.global_tags
}

################## CODE-PIPELINE ##################

resource "aws_codepipeline" "codepipeline" {
  for_each = toset(var.repo_branches)

  name     = "${var.app_name_prefix}-${terraform.workspace}-${each.value == replace(each.value, "feature/", "f_") ? replace(each.value, "release/", "r_") : replace(each.value, "feature/", "f_")}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
    # Uses standard S3 encryption

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source-code"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.source_repo.arn
        FullRepositoryId = aws_ssm_parameter.repo_id.value
        BranchName       = each.value
      }
    }
  }

  stage {
    name = "IaC_Plan_Execution"

    action {
      name             = "Terraform_Plan"
      namespace        = "PlanVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source-code"]
      output_artifacts = ["plan"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_Message"
            value = "#{SourceVariables.CommitMessage}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "PLAN"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "IaC_Plan_Approval"

    action {
      name             = "Approve"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
      input_artifacts  = []
      output_artifacts = []
      configuration = {
        CustomData = "Approve IaC changes"
      }
    }
  }

  tags = local.global_tags
}

################## CODESTAR CONNECTION ##################

resource "aws_codestarconnections_connection" "source_repo" {
  name          = "${var.app_name_verbose}-repo-connection"
  provider_type = "GitHub"
  tags          = local.global_tags
}

################## CODE-BUILD ##################

resource "aws_codebuild_project" "terraform_build" {
  name          = "${var.app_name_prefix}-${terraform.workspace}"
  description   = "${var.app_name_verbose} Terraform Plan/Apply jobs"
  badge_enabled = false
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "WORKSPACE"
      value = terraform.workspace
    }

    environment_variable {
      name  = "TF_VERSION"
      value = aws_ssm_parameter.terraform_version.name
      type  = "PARAMETER_STORE"
    }
  }

  /*
  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }
  */

  source {
    type = "CODEPIPELINE"
  }

  tags = local.global_tags
}
