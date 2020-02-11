provider "aws" {
  region     = "{$ .aws_region $}"
  access_key = "{$ .aws_access_key $}"
  secret_key = "{$ .aws_secret_key $}"
}
{$ $name := printf "%s" .uniq_name $}
terraform {
  backend "consul" {
    address="consul.service.infra1.consul:8500"
    scheme  = "http"
    path    = "tf/states/faceless-algo/{$ $name $}"
  }
}
