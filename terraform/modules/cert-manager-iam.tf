

data "aws_iam_policy_document" "certmanager-role" {
  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }



  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }


  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "certmanager" {
  name        = "certmanager-policy"
  description = "Policy for Cert manager to manage Route53"
  policy      = data.aws_iam_policy_document.certmanager-role.json
}

data "aws_iam_openid_connect_provider" "eks" {
  arn = module.eks.oidc_provider_arn
}


resource "aws_iam_role" "certmanager" {
  name = "certmanager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:cert-manager:cert-manager"
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}




resource "aws_iam_role_policy_attachment" "certmanager" {
  role       = aws_iam_role.certmanager.name
  policy_arn = aws_iam_policy.certmanager.arn
}

output "certmanager_role_arn" {
  value = aws_iam_role.certmanager.arn
} 