Terraform 0.12 code to create AWS virtual machine, intended to host algo based VPN server.

Please refer to https://github.com/trailofbits/algo for further details.

Usage: clone this repo, copy provision.tpl.sh to provision.sh, fill values (if you are not use instantiator).
Also you should delete or change `terraform` block in main.tf to use yout preferred remote state storafe, or local state storage
Now you can run `terraform init` and `terraform apply`.