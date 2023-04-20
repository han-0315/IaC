output "contents_bucket_id" {
  description = "S3 Bucket Name for Contents"
  value       = aws_s3_bucket.contents_bucket.id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "bucket_policy" {
  description = "S3 Bucket Policy"
  value       = aws_s3_bucket_policy.contents_bucket_policy.policy
}