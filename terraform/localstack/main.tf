terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://100.117.35.70:4566"
    dynamodb = "http://100.117.35.70:4566"
  }
}

resource "aws_s3_bucket" "homelab_storage" {
  bucket = "tf-homelab-storage-bucket"

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = "Swapnaj"
  }
}
