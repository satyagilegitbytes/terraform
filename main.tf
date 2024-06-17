# main.tf

provider "aws" {
  region = "ap-southeast-1"  # Set to your desired AWS region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"  # Replace with a unique name
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.my_bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""  # Empty if there's no default object

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.my_bucket.id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"  # No geo restrictions
    }
  }
}

output "cdn_url" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
}
