resource "aws_s3_bucket" "s3-static-web-server" {
  bucket = "hanggi-static-web-server"
}

resource "aws_s3_bucket_website_configuration" "s3-static-web-server" {
  bucket = aws_s3_bucket.s3-static-web-server.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "s3-static-web-server" {
  bucket = aws_s3_bucket.s3-static-web-server.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_ownership_controls" "s3-static-web-server" {
  bucket = aws_s3_bucket.s3-static-web-server.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-static-web-server" {
  bucket = aws_s3_bucket.s3-static-web-server.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3-static-web-server" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-static-web-server,
    aws_s3_bucket_public_access_block.s3-static-web-server,
  ]

  bucket = aws_s3_bucket.s3-static-web-server.id
  acl    = "public-read"
}


output "website_url" {
  value = "http://${aws_s3_bucket.s3-static-web-server.bucket}.s3-website.us-west-2.amazonaws.com"
}