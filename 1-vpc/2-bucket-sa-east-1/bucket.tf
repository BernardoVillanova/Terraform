provider "aws" {
  region = "sa-east-1"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "simple-bucket-bernardo"

  tags = { 
    Name = "simple bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read-write" #tornar o bucket publico
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.mybucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.mybucket.arn}/*",
    ]
  }
}

output "bucket_fqdn" {
  value       = aws_s3_bucket.mybucket.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_domain" {
  value       = aws_s3_bucket.mybucket.id
  description = "Bucket Name (aka ID)"
}