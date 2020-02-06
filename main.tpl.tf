provider "aws" {
  region     = "{$ .P.aws_region $}"
  access_key = "{$ .P.aws_access_key $}"
  secret_key = "{$ .P.aws_secret_key $}"
}
