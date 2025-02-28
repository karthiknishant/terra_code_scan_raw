provider "aws" {
  region = "us-west-2"
}

# Security Group with exactly two violations: 
# - One non-standard port exposed to 0.0.0.0/0 (violates PUBLIC_PORTS_ACCESS)
# - One restricted port exposed to 0.0.0.0/0 (violates RESTRICTED_PORTS_ACCESS)
resource "aws_security_group" "test_sg" {
  name        = "test-security-group"
  description = "Test security group with violations"

  # Violation of PUBLIC_PORTS_ACCESS (non-standard port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Violation of RESTRICTED_PORTS_ACCESS (MySQL port 3306)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Compliant rules (standard web ports)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] 
  }
}

# S3 bucket with public read access (violates S3_BUCKET_GLOBAL_READ)
resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-name"
}

resource "aws_s3_bucket_public_access_block" "test_bucket_access" {
  bucket = aws_s3_bucket.test_bucket.id
  
  block_public_acls       = true
  block_public_policy     = false  # Part of violation
  ignore_public_acls      = true
  restrict_public_buckets = false  # Part of violation
}

resource "aws_s3_bucket_policy" "test_bucket_policy" {
  bucket = aws_s3_bucket.test_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"  # Violation: allows public access
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.test_bucket.arn}/*"
      }
    ]
  })
}

# RDS instance with public access (violates RDS_PUBLIC_ACCESS)
resource "aws_db_instance" "test_db" {
  identifier           = "test-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  skip_final_snapshot = true
  
  username = "admin"
  password = "temporarypassword123" 
  
  publicly_accessible = true
  
  vpc_security_group_ids = [aws_security_group.test_sg.id]
}
