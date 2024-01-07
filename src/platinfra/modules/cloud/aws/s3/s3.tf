resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}
