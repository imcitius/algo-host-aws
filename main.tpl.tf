provider "aws" {
  region     = "{$ .P.aws_region $}"
  access_key = "{$ .P.aws_access_key $}"
  secret_key = "{$ .P.aws_secret_key $}"
}

terraform {
  backend "pg" {
    conn_str = "postgres://terraform:{$ .P.pg_password $}@pgsql-main.service.{$ .P.Datacenter $}.consul/terraform_backend"
    schema_name = "{$ .P.tf_workspace $}"
  }
}
