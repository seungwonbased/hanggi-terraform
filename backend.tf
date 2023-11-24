provider "aws" {
  region = "us-west-2"
}


resource "aws_s3_bucket" "terraform-backend" {
  bucket = "hanggi-terraform-state-backend"

  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_s3_bucket_versioning" "terraform-backend-versioning" {
  bucket = aws_s3_bucket.terraform-backend.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-backend-encryption" {
  bucket = aws_s3_bucket.terraform-backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "terraform-backend-public-access" {
  bucket                  = aws_s3_bucket.terraform-backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_dynamodb_table" "terraform-state-lock" {
  name         = "hanggi-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


output "terraform-backend-arn" {
  value       = aws_s3_bucket.terraform-backend.arn
  description = "The ARN of the Terraform Backend S3 bucket"
}


output "dynamodb-name" {
  value       = aws_dynamodb_table.terraform-state-lock.name
  description = "The name of the DynamoDB table"
}