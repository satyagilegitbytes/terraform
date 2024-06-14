provider "aws" {
  region = "your_aws_region"
}

resource "aws_s3_bucket" "terraform_test_bucket" {
  bucket = "terraform-test-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_object" "test_folder" {
  bucket = aws_s3_bucket.terraform_test_bucket.bucket
  key    = "test/"
  acl    = "private"
}
