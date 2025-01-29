provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "app_security_group_test1" {
  name        = "app-security-group-test1"
  description = "Security group for application testing"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "data_bucket_test1" {
  bucket = "data-storage-test1"
}

resource "aws_s3_bucket_public_access_block" "bucket_access_test1" {
  bucket = aws_s3_bucket.data_bucket_test1.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy_test1" {
  bucket = aws_s3_bucket.data_bucket_test1.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.data_bucket_test1.arn}/*"
      },
    ]
  })
}