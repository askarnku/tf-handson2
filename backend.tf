provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "askar-backend"
    region = "us-east-1"
    key    = "tf-handson2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.66.0"
    }
  }

}
