data "aws_iam_policy_document" "externaldns" {
statement {
effect = "Allow"
actions = [
"route53:ChangeResourceRecordSets"
]
resources = [
"arn:aws:route53:::hostedzone/*"
]
}

statement {
effect = "Allow"
actions = [
"route53:ListHostedZones",
"route53:ListResourceRecordSets"
]
resources = ["*"]
}
}

# Create the IAM policy

resource "aws_iam_policy" "externaldns" {
name        = "externaldns-policy"
description = "Policy for ExternalDNS to manage Route53"
policy      = data.aws_iam_policy_document.externaldns.json
}

# Get OIDC provider from EKS module

data "aws_iam_openid_connect_provider" "eks" {
arn = module.eks.oidc_provider_arn
}

# IAM Role for ExternalDNS with IRSA trust policy

resource "aws_iam_role" "externaldns" {
name = "externaldns-role"

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
"${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:external-dns:external-dns"
"${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
}

}
}]
})
}

# Attach Route53 policy to the IRSA role

resource "aws_iam_role_policy_attachment" "externaldns_irsa" {
role       = aws_iam_role.externaldns.name
policy_arn = aws_iam_policy.externaldns.arn
}

# Output the role ARN

output "externaldns_role_arn" {
value = aws_iam_role.externaldns.arn
}