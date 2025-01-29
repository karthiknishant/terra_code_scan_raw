provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "app_security_group_test2" {
  name        = "app-security-group-test2"
  description = "Security group for application testing"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/12"]
  }
}

resource "aws_s3_bucket" "data_bucket_test2" {
  bucket = "data-storage-test2"
}

resource "aws_s3_bucket_public_access_block" "bucket_access_test2" {
  bucket = aws_s3_bucket.data_bucket_test2.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy_test2" {
  bucket = aws_s3_bucket.data_bucket_test2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RestrictedAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/specific-role"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.data_bucket_test2.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp": "10.0.0.0/8"
          }
        }
      },
    ]
  })
}