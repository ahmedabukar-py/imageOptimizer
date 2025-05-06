data "aws_secretsmanager_secret" "cloudfront_keys" {
  name = "cloudfrontKeyGen"  # Replace with the actual name of your secret
}

data "aws_secretsmanager_secret_version" "cloudfront_keys_version" {
  secret_id = data.aws_secretsmanager_secret.cloudfront_keys.id
}


# For debugging - output the secret structure
output "secret_string" {
  value = jsondecode(data.aws_secretsmanager_secret_version.cloudfront_keys_version.secret_string)
  sensitive = true
}

# Extract the keys from the JSON object stored in the secret
locals {
  cloudfront_private_key = jsondecode(data.aws_secretsmanager_secret_version.cloudfront_keys_version.secret_string)["private_key"]
  cloudfront_public_key  = jsondecode(data.aws_secretsmanager_secret_version.cloudfront_keys_version.secret_string)["public_key"]
}

