terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "playground"
  default_tags {
    tags = {
      creator = "terraform"
      goal    = "haunted_house_provider"
    }
  }
}

provider "github" {
  token = var.github_token # Alternatively use GITHUB_TOKEN
}
