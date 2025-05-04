variable "region" {
  description = "Region to deploy resource"
  type        = string
}

variable "cloudfront_key_pair_id" {
  description = "CloudFront key pair ID used for signing URLs"
  type        = string
}

variable "cloudfront_private_key" {
  description = "Private key used for signing CloudFront URLs"
  type        = string
  sensitive   = true
}
