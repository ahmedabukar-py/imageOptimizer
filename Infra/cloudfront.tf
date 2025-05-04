resource "aws_cloudfront_distribution" "optimized_images" {
  origin {
    domain_name = aws_s3_bucket.optimized_images.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.optimized_images.bucket

    s3_origin_config {
      origin_access_identity = "" # <-- Added: Required even when using OAC (Terraform constraint)
    }
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id # Use the OAC ID here
  }



  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html" # Optional if you have a default landing page

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.optimized_images.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  price_class = "PriceClass_100" # Choose based on your region requirements
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "image-optimizer-oac"
  description                       = "Access control for CloudFront to S3"
  origin_access_control_origin_type = "s3"
  # Using the managed policy provided by AWS
  signing_behavior = "always" # This allows CloudFront to sign requests to the S3 bucket
  # Control the access level to the origin
  signing_protocol = "sigv4" # This ensures secure signature is used
}


