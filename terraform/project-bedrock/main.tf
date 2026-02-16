module "vpc" {
  source  = "./vpc"
  project = var.project
}

module "eks" {
  source   = "./eks"
  cluster_name = "project-bedrock-cluster"
  subnets  = module.vpc.public_subnets
  project  = var.project
}

module "iam" {
  source = "./iam"
}

module "logging" {
  source       = "./logging"
 cluster_name = module.eks.cluster_name
}

module "s3_lambda" {
  source     = "./s3-lambda"
  student_id = var.student_id
  project    = var.project
}
