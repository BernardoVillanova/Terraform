provider "aws" {
  region = "sa-east-1"
}

resource "aws_ecr_repository" "default" {
  name                 = "ecr-archi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}