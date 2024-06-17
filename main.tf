# main.tf

provider "aws" {
  region = "ap-southeast-1"  # Use the region specified in your Jenkins environment
}

variable "user_id" {}
variable "game_id" {}

resource "aws_s3_bucket" "game_bucket" {
  bucket = "game-build-bucket-${var.user_id}-${var.game_id}"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "game_build" {
  bucket = aws_s3_bucket.game_bucket.bucket
  key    = "game-build.zip"
  source = "game-build.zip"  # This should be the path to the actual build file
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.game_bucket.bucket_regional_domain_name
    origin_id   = "${var.user_id}-${var.game_id}"

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
    target_origin_id = "${var.user_id}-${var.game_id}"

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
