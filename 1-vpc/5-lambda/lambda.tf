provider "aws" {
  region = "sa-east-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "teste-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "teste-lambda" {
  filename      = "lambda_function.zip"
  function_name = "teste-lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  runtime = "python3.9"
}