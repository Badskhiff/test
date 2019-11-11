resource "aws_iam_role" "sns_role" {
  name               = "sns_role"
  assume_role_policy = file("sns_polisy.json")
}