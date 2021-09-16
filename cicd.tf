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
  /*
  stage {
    name = "Plan"

    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source-code"]
      output_artifacts = ["plan"]
      version          = "1"

      configuration = {
        ProjectName = var.app_name_verbose
      }
    }
  }
*/
  stage {
    name = "Approval"

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
