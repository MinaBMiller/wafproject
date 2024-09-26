output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static website"
  value       = aws_s3_bucket.static_website.id
}

output "s3_website_endpoint" {
  description = "S3 static website hosting endpoint"
  value       = aws_s3_bucket_website_configuration.static_website.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_website_distribution.id
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.static_website_distribution.domain_name
}

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.static_website_waf.id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.static_website_waf.arn
}

output "cloudfront_oai_iam_arn" {
  description = "IAM ARN of the CloudFront Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
}