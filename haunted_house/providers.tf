terraform {
  backend "s3" {
    bucket     = "haunted-house-skeletons"
    key        = "core/terraform.tfstate"
    region     = "eu-west-1"
    kms_key_id = "alias/boundary_state-key"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "playground"
  default_tags {
    tags = {
      creator = "terraform"
      goal    = "haunted_house"
    }
  }
}

provider "tls" {}
provider "local" {}
