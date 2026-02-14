provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "./vpc/main.tf"
  project = var.project
}

module "eks" {
  source   = "./eks/main.tf"
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.public_subnets
  project  = var.project
}

module "iam" {
  source = "./iam/dev-view-user.tf"
}

module "logging" {
  source       = "./logging/cloudwatch.tf"
  cluster_name = module.eks.cluster_name
}

module "s3_lambda" {
  source     = "./s3-lambda/main.tf"
  student_id = var.student_id
  project    = var.project
}
