terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "arnav"
}

# needed for creating lb controller
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

variable "cluster_name" {
  default = "tf-cluster"
}

variable "api_gw_name" {
  default = "tf-cluster-api"
}