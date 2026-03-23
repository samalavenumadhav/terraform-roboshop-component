terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.33.0"
    }
  }
    backend "s3" {
      bucket         = "samala-99"
      key            = "roboshop-dev-vpc"
      region         = "us-east-1"
      encrypt        = true
      use_lockfile = true
      force_path_style = true 
    }
}

provider "aws" {
  # Configuration options

   region ="us-east-1"
}
