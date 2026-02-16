variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}