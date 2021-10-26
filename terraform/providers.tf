terraform {
  backend "remote" {
    organization = "powerx"
    workspaces {
      name = "amongus-todo"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.54"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}