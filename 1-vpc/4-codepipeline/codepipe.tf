provider "aws" {
  region = "sa-east-1"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"
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
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "codebuild:BatchGetBuildBatches",
                "devicefarm:GetRun",
                "codedeploy:CreateDeployment",
                "rds:*",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeploymentConfig",
                "cloudformation:CreateChangeSet",
                "autoscaling:*",
                "cloudformation:DeleteChangeSet",
                "codebuild:BatchGetBuilds",
                "devicefarm:ScheduleRun",
                "codecommit:GetCommit",
                "devicefarm:ListDevicePools",
                "codestar-connections:UseConnection",
                "cloudformation:UpdateStack",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "devicefarm:ListProjects",
                "codedeploy:GetApplication",
                "cloudformation:SetStackPolicy",
                "codecommit:UploadArchive",
                "lambda:ListFunctions",
                "s3:*",
                "codedeploy:RegisterApplicationRevision",
                "lambda:InvokeFunction",
                "cloudformation:*",
                "devicefarm:CreateUpload",
                "elasticloadbalancing:*",
                "codecommit:CancelUploadArchive",
                "devicefarm:GetUpload",
                "cloudformation:DescribeStacks",
                "elasticbeanstalk:*",
                "codecommit:GetUploadArchiveStatus",
                "cloudwatch:*",
                "codecommit:GetRepository",
                "cloudformation:CreateStack",
                "codecommit:GetBranch",
                "cloudformation:DeleteStack",
                "codebuild:StartBuildBatch",
                "ecr:DescribeImages",
                "ecs:*",
                "codedeploy:GetDeployment",
                "ec2:*",
                "codebuild:StartBuild",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "example" {
  name = "example"

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
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.name

  policy = <<POLICY
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
                "logs:PutLogEvents",
                "ssm:GetParameters",
                "ecr:GetAuthorizationToken"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-sa-east-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
                
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::simple-bucket-julioleite",
                "arn:aws:s3:::simple-bucket-julioleite/*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:s3:::simple-bucket-julioleite",
                "arn:aws:s3:::simple-bucket-julioleite/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_codebuild_project" "example" {
  name          = "test-project"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type            = "GITHUB"
    location        = ""
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }
}

resource "aws_codepipeline" "terraform" {
  name     = "terraform-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:sa-east-1:1234567890:connection/abcde-c1234-4567-abcd-1234567890"
        FullRepositoryId = ""
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "test-project"
      }
    }
  }

}


