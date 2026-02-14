resource "aws_iam_user" "dev" {
  name = "bedrock-dev-view"
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.dev.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "dev" {
  user = aws_iam_user.dev.name
}

output "dev_access_key" {
  value     = aws_iam_access_key.dev.id
  sensitive = true
}

output "dev_secret_key" {
  value     = aws_iam_access_key.dev.secret
  sensitive = true
}
