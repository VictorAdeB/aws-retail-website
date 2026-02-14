resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/project-bedrock-cluster"
  retention_in_days = 3
}
