terraform {
  backend "s3" {
    bucket         = "image-optimizer-backend"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # Optional
  }
}