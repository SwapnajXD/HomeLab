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
  # 📍 These credentials do not need to be real since LocalStack accepts any strings
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "us-east-1"

  # 🔐 Overrides default production cloud credential validation checks
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # 🚀 Redirects API workflows directly across Tailscale to your Ubuntu VM endpoint
  endpoints {
    s3       = "http://100.117.35.70:4566"
    dynamodb = "http://100.117.35.70:4566"
  }
}
