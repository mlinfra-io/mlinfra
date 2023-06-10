resource "aws_s3_bucket" "vpc_logs_bucket" {
  bucket = "ultimate-mlops-vpc-flowlogs-bucket"
  tags   = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs_lifecycle" {
  bucket = aws_s3_bucket.vpc_logs_bucket.id

  rule {
    filter {
      prefix = "AWSLogs/"
    }

    id     = "MoveLogsToGlacier"
    status = "Enabled"

    transition {
      days          = 10
      storage_class = "GLACIER"
    }

    expiration {
      days = 60
    }
  }
}
