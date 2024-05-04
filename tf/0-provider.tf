terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "arnav-first-1"
}

# needed for creating lb controller
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

variable "vpc_name" {
  default = "fastapi-vpc"
}

variable "igw_name" {
  default = "fastapi-igw"
}

variable "natgw_name" {
  default = "fastapi-natgw"
}

variable "private_rt_name" {
  default = "fastapi-private-rt"
}

variable "public_rt_name" {
  default = "fastapi-public-rt"
}

variable "alb_sg_name" {
  default = "fastapi-alb"
}

variable "eks_role_name" {
  default = "fastapi-eks-role"
}

variable "kube_profile_role_name" {
  default = "fastapi-kube-profile-role"
}


variable "cluster_name" {
  default = "fastapi-cluster"
}

variable "fargate_default_profile_name" {
  default = "kube-system"
}

variable "fargate_custom_profile_name" {
  default = "fastapi-profile"
}

variable "fargate_custom_profile_namespace" {
  default = "staging"
}

variable "cognito_name" {
  default = "fastapi-cognito"
}

variable "cognito_client_name" {
  default = "fastapi-cognito-client"
}

variable "api_gw_name" {
  default = "tf-cluster-api"
}
