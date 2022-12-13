terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.42.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}