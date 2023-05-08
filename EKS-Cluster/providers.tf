# Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.4"
     }
  }
  #  Backend as S3
  backend "s3" {
    bucket = "my-sosobucket-1"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1" 
 
    #  State Locking
    dynamodb_table = "soso-dynamo1"    
  }  
}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}

### Adding Kubectl provider for flux
