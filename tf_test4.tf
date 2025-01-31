resource "aws_security_group" "app_server" {
  name        = "application_server_sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Application port access"
  }
}

resource "aws_security_group" "db_access" {
  name        = "database_access_sg"
  description = "Database connection security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL access"
  }
}

resource "aws_s3_bucket" "asset_storage" {
  bucket = "company-assets-storage-2024"
}

resource "aws_s3_bucket_policy" "asset_access" {
  bucket = aws_s3_bucket.asset_storage.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AssetAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.asset_storage.arn}/*"]
      }
    ]
  })
}

resource "aws_db_instance" "reporting_db" {
  identifier           = "reporting-database"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  skip_final_snapshot = true
  publicly_accessible = true
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
    Environment = "production"
  }
}

resource "aws_sns_topic" "notifications" {
  name = "system-notifications"
}

resource "aws_sns_topic_policy" "notifications_policy" {
  arn = aws_sns_topic.notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sns:DeleteTopic"
        Resource  = aws_sns_topic.notifications.arn
      }
    ]
  })
}