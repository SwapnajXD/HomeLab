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

resource "aws_dynamodb_table" "homelab_db" {
  name         = "tf-homelab-metadata"
  billing_mode = "PAY_PER_REQUEST" # On-demand scaling (perfect for local environments)
  hash_key     = "LockID"         # The primary partition key

  attribute {
    name = "LockID"
    type = "S" # "S" stands for String data type
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Project     = "Cloud-Sentinel"
  }
}
