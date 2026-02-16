resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"   # ← correct format + dynamic
  retention_in_days = 3

  tags = {
    Project = "project-bedrock"   # optional
  }
}