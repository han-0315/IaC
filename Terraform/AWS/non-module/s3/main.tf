locals {
  additional_tags = {
    Terraform   = "true"
    Environment = var.environment
    Purpose     = var.purpose
    Owner       = var.owner
  }
}

resource "aws_s3_bucket" "contents_bucket" {
  bucket = var.contents_bucket_name

  tags = merge(
    {
      Name = "${var.namespace}-content-bucket"
    },
    local.additional_tags
  )
}

resource "aws_s3_bucket_policy" "contents_bucket_policy" {
  bucket = aws_s3_bucket.contents_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccessFromCloudFront"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.contents_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${aws_cloudfront_distribution.cloudfront_distribution.arn}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "contents_bucket_acl" {
  bucket = aws_s3_bucket.contents_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "logging_bucket" {
  count  = var.enable_logging ? 1 : 0
  bucket = var.logging_bucket_name

  tags = merge(
    {
      Name = "${var.namespace}-logging-bucket"
    },
    local.additional_tags
  )
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logging_bucket[0].id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Sid    = "S3ServerAccessLogsPolicy",
      Effect = "Allow",
      Principal = {
        Service = "logging.s3.amazonaws.com"
      },
      Action   = ["s3:PutObject"],
      Resource = "${aws_s3_bucket.logging_bucket[0].arn}/*",
      Condition = {
        ArnLike = { "AWS:SourceArn" = "${aws_s3_bucket.contents_bucket.arn}" }
      }
    }]
  })
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logging_bucket[0].id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "contents_bucket_logging" {
  count         = var.enable_logging ? 1 : 0
  bucket        = aws_s3_bucket.contents_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket[0].id
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "contents_bucket_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.contents_bucket.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
}

resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "${var.namespace}-cloudfront-oac"
  description                       = "CloudFront Origin Access Control for ${var.namespace}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "s3-${var.contents_bucket_name}"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name              = aws_s3_bucket.contents_bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront Distribution for S3 Bucket `${var.contents_bucket_name}`"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string            = true
      query_string_cache_keys = ["d"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging_bucket[0].bucket_domain_name
    prefix          = "cloudfront/"
  }

  tags = merge(
    {
      Name = "${var.namespace}-cloudfront-distribution"
    },
    local.additional_tags
  )
}
