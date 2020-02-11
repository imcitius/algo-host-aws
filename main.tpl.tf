provider "aws" {
  region     = "{$ .P.aws_region $}"
  access_key = "{$ .P.aws_access_key $}"
  secret_key = "{$ .P.aws_secret_key $}"
}

// terraform {
//   backend "pg" {
//     conn_str = "postgres://terraform:{$ .P.pg_password $}@pgsql-main.service.{$ .P.Datacenter $}.consul/terraform_backend"
//     schema_name = "{$ .P.tf_workspace $}"
//   }
// }

terraform {
  backend "consul" {
    address = "consul.service.infra1.consul:8500"
    scheme  = "http"
    path    = "tf/states/faceless-algo-test%3A{$ .P.tf_workspace $}"
  }
}
