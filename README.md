Terraform 0.12 code to create AWS virtual machine, intended to host algo based VPN server.

Please refer to https://github.com/trailofbits/algo for further details.

Usage: clone this repo, copy provision.tpl.sh to provision.sh, fill values (if you are not use instantiator).
Also remove all lines starting from `#### Upload confgi artifacts to backend` till end of file (probably you not need this).

Please edit or delete `terraform backend` block in main.tf to use your preferred remote state storage, or local state storage.

Now you can run `terraform init` and `terraform apply`.