variable "subnets" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}
