provider "aws" {
  region = var.waf_region
}

# Create S3 bucket for static website
resource "aws_s3_bucket" "static_website" {
  bucket = var.bucket_name
  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index-waf.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_website.arn}/*"
      },
    ]
  })
}

# Create AWS WAF web ACL
resource "aws_wafv2_web_acl" "static_website_waf" {
  name        = "static-website-waf-${random_id.suffix.hex}"
  description = "WAF for static website"
  scope       = "CLOUDFRONT"

  tags = {
    Name = var.static_waf
  }

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = false
    }
  }
 
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = false
    }
  }

  rule {
  name     = "AWSManagedRulesCommonRuleSet"
  priority = 3

  override_action {
      count {}
    }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWSManagedRulesCommonRuleSet"
    sampled_requests_enabled   = true
  }
}

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = false
    }
  }

  # Add 3 custom rules here

  # Rule 1: Block requests from specific IP addresses

  rule {
    name     = "block-specific-ips"
    priority = 5

    action {
      count {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockedIPs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: Rate limit requests based on IP

  rule {
    name     = "rate-limit-ips"
    priority = 6

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitIPs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: Geo-blocking (block requests from specific countries)

  rule {
    name     = "geo-block-countries"
    priority = 7

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["RU", "CN", "GB"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoBlockCountries"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "static-website-waf"
    sampled_requests_enabled   = true
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# IP set for Rule 1
resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "blocked-ips"
  description        = "IP set for blocked IPs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.0/24", "198.51.100.0/24"]
}

# Associate WAF with S3 bucket
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for static website"
}



resource "aws_cloudfront_distribution" "static_website_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = "static-website"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static website distribution"
  default_root_object = "index-waf.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "static-website"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
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

  web_acl_id = aws_wafv2_web_acl.static_website_waf.arn
}