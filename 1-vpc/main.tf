provider "aws" {
   region = "sa-east-1"
 }

 module "bucket" {
    source = "./2-bucket-sa-east-1"
 }

 module "ecr" {
  source = "./3-ecr"
 }

 module "codepipe" {
  source = "./4-codepipeline"
 }

 module "lambda" {
  source = "./5-lambda"
 }

 module "cloudfront" {
  source = "./6-cloundfront"
 }