resource "aws_iam_policy" "url_shortener_dynamodb" {
  name        = "url-shortner-dynamodb-policy"
  description = "Allows URL shortener pods to access dynamoDB table"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:Putitem",
          "dynamodb:Getitem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.url_shortener.arn
      },
    ]
  })

  tags = {
    Project     = "url-shortener"
    Environment = "dev"
  }

}


resource "aws_iam_role" "url_shortener" {
  name        = "url-shortener-pod-role"
  description = "IAM role for URL shortener Kubernetes pods"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:url-shortener"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Project     = "url-shortener"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}


resource "aws_iam_role_policy_attachment" "url_shortener_dynamodb" {
  role       = aws_iam_role.url_shortener.name
  policy_arn = aws_iam_policy.url_shortener_dynamodb.arn
}



