terraform {
  backend "s3" {
    bucket               = "terraformbucketnew"  # Existing bucket name
    key                  = "terraform.tfstate"
    workspace_key_prefix = "workspaces"
    region               = "ap-south-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
  }
}

