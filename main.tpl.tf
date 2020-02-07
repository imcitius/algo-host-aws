provider "aws" {
  region     = "{$ .P.aws_region $}"
  access_key = "{$ .P.aws_access_key $}"
  secret_key = "{$ .P.aws_secret_key $}"
}
{$ $name := printf "%s_%s" .I.ProjectName .I.Name $}
terraform {
  backend "pg" {
    schema_name="{$ $name $}"
    skip_schema_creation=false
  }
}
