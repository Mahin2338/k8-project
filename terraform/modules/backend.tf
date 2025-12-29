terraform {
  backend "s3" {
    bucket         = "eks-terraform-state-1765262697"
    key            = "eks/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-eks"
  }
}