terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-state-s3"
    region         = "us-east-1"
    profile        = "someprofile"
    role_arn       = "arn:aws:iam::"
    key            = "terraform-state/client.tfstate"
  }
}