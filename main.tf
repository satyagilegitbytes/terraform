# main.tf

provider "aws" {
  region = "ap-southeast-1"  # Adjust as necessary
}

variable "bucket_name" {
  description = "The name of the existing S3 bucket"
}

variable "origin_path" {
  description = "Path in the S3 bucket (optional)"
  default     = ""
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${var.bucket_name}.s3.amazonaws.com"
    origin_id   = "${var.bucket_name}-origin"
    origin_path = var.origin_path

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.bucket_name}-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cdn_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
