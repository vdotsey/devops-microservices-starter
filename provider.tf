

# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "6.2.0"
#     }
#   }
# }

# provider "aws" {
#   # Configuration options
#     region = "eu-north-1"  # Change to your desired AWS region  
# }

terraform {
  # Backend configuration (S3 for state storage)
  backend "s3" {
    bucket         = "terraform-devops-backend-file-v1"
    region         = "eu-north-1"  # Region where the S3 bucket exists
    key            = "terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock"  # Recommended for state locking (replace with your DynamoDB table name)
  }

  # Provider requirements
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region = "eu-north-1"  # Region where resources will be deployed
}

