provider "aws" {
  region     = "{$ .aws_region $}"
  access_key = "{$ .aws_access_key $}"
  secret_key = "{$ .aws_secret_key $}"
}

terraform {
  backend "http" {
    address = "http://terraform-state-store.service.{$ .datacenter $}.consul/v1/state/{$ .uniq_name $}"
    lock_address = "http://terraform-state-store.service.{$ .datacenter $}.consul/v1/state/{$ .uniq_name $}"
    unlock_address = "http://terraform-state-store.service.{$ .datacenter $}.consul/v1/state/{$ .uniq_name $}"
    username = "algo-personal"
    password = "any"
  }
}
