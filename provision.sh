#!/bin/sh
git clone https://github.com/trailofbits/algo.git
cd algo
SERVER_IP=`cat ../private_ip.txt`

# create virtual environment
python3 -m virtualenv --python="$(command -v python3)" .env &&
  source .env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r requirements.txt

#deploy algo
ansible-playbook main.yml -e "provider=local \
                              server=${SERVER_IP} \
                              endpoint={{server}} \
                              server_name=algo \
                              ondemand_cellular=true \
                              ondemand_wifi=true \
                              dns_adblocking=false \
                              ssh_tunneling=false \
                              store_pki=true \
                              ondemand_wifi_exclude='' \
                              ondemand_cellular=true \
                              ssh_user=ubuntu \
                              ansible_port=22"
