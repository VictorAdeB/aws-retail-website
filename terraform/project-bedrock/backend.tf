terraform {
  backend "s3" {
    bucket       = "bedrock-tf-alt-soe-025-0421"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

