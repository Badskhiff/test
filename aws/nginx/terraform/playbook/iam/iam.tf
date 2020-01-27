provider "aws" {
  region  = "us-east-2"
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
module "sns" {
  source                              = ".//../../modules/iam"
}
