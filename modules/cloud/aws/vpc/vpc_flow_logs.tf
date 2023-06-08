resource "aws_s3_bucket" "vpc_logs_bucket" {
  bucket = "vpc-flow-logs-bucket"
  tags   = local.tags
}

resource "aws_s3_bucket_acl" "vpc_logs_bucket_acl" {
  bucket = aws_s3_bucket.vpc_logs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs_lifecycle" {
  bucket = aws_s3_bucket.vpc_logs_bucket.id

  rule {
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
