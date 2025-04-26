resource "aws_s3_bucket" "original_images" {
  bucket        = "image-optimizer-originals"
  force_destroy = true

  tags = {
    Name        = "OriginalImages"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "optimized_images" {
  bucket        = "image-optimizer-optimized"
  force_destroy = true

  tags = {
    Name        = "OptimizedImages"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "originals_block" {
  bucket = aws_s3_bucket.original_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "optimized_block" {
  bucket = aws_s3_bucket.optimized_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional: Versioning
resource "aws_s3_bucket_versioning" "originals_versioning" {
  bucket = aws_s3_bucket.original_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "optimized_versioning" {
  bucket = aws_s3_bucket.optimized_images.id
  versioning_configuration {
    status = "Enabled"
  }
}
