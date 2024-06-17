# main.tf

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "02-terraform-test-bucket"

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Test"
  }
}

# This example assumes public read access for testing purposes; adjust as needed
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
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

  restrictions {
    geo_restriction {
      restriction_type = "none"  # No geo restrictions
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "My CloudFront Distribution"
  }
}

variable "bucket_name_prefix" {
  default = "01"  # Replace with a unique prefix
}

output "cdn_url" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
}
