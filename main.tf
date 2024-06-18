# main.tf

provider "aws" {
  region = "ap-southeast-1" # Replace with your preferred region
}

# Create the S3 bucket folder (prefix)
resource "aws_s3_object" "folder" {
  bucket = "test-teraform-001" # Replace with your bucket name
  key    = "folder-name/"             # The trailing slash denotes a folder (prefix)
}

# Set ACL for the S3 bucket
resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = "test-teraform-001" # Replace with your bucket name
  acl    = "private"
}

# Create the CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "Allow CloudFront to access S3 bucket"
}

# Create the CloudFront distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "test-teraform-001.s3.amazonaws.com"
    origin_id   = "S3-test-teraform-001"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "" # Set to "index.html" or appropriate file if needed

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-test-teraform-001"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

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
