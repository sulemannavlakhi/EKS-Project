terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket       = "sulemans3"
    key          = "terraform.tfstate"
    region       = "ca-central-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "ca-central-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "2048-game"
      ManagedBy   = "terraform"
      Owner       = "suleman"
    }
  }
}