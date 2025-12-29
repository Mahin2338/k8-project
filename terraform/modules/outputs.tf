output "url_shortener_role_arn" {
  value       = aws_iam_role.url_shortener.arn
  description = "ARN of IAM role for URL shortener pods"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.url-app.repository_url
}