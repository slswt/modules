module "release_info" {
  source = "github.com/slswt/modules//utils/release_info"
}

locals {
  s3_origin_id = "${var.origin_id}-${module.release_info.environment}-${module.release_info.version}"
}

resource "aws_s3_bucket" "origin" {
  bucket = "${local.s3_origin_id}"
  acl    = "private"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = "${aws_s3_bucket.origin.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

  comment = "${local.s3_origin_id}"

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"
    compress         = true

    forwarded_values {
      query_string = false
      headers      = "${var.forwarded_headers}"

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 31536000

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = "${aws_lambda_function.simple_lambda.*.qualified_arn[0]}"
      include_body = false
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"
}
