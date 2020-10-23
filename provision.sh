#!/bin/bash
SERVER_IP=`cat private_ip.txt`

# check RKN blacklist
if [[ `curl "http://ip-checker.service.{$ .datacenter $}.consul/check?ip=${SERVER_IP}" | grep true` ]]; then
  echo found in blacklist
  exit 13
fi

rm -rf algo || bin/true
git clone https://github.com/trailofbits/algo.git
cd algo

# create virtual environment
python3 -m virtualenv --python="$(command -v python3)" .env &&
  source .env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r requirements.txt

# patching playbooks
sed -i "s/if tests|default(false)|bool/if tests|default(true)|bool/g" server.yml
sed -i "s/--dport {{ ansible_ssh_port }}/-m multiport --dports {{ ansible_ssh_port }},443/" roles/common/templates/rules.v4.j2
sed -i "s/-A FORWARD -m conntrack --ctstate NEW -s {{ strongswan_network }} -m policy --pol ipsec --dir in -j ACCEPT/-A FORWARD -s {{ strongswan_network }} -j ACCEPT/g" roles/common/templates/rules.v4.j2
sed -i "s/-A FORWARD -m conntrack --ctstate NEW -s {{ wireguard_network }} -m policy --pol ipsec --dir in -j ACCEPT/-A FORWARD -s {{ wireguard_network }} -j ACCEPT/g" roles/common/templates/rules.v4.j2
sed -i "s/nameConstraints = {{ nameConstraints }}/#nameConstraints = {{ nameConstraints }}/" roles/strongswan/templates/openssl.cnf.j2
sed -i "s/(\[wireguard_network_ipv4\] if wireguard_enabled else \[\])/([wireguard_network_ipv4] if wireguard_enabled else []) + ([openvpn_network])/" roles/common/templates/rules.v4.j2
sed -i "s/-A FORWARD -s {{ strongswan_network }} -j ACCEPT/-A FORWARD -s {{ strongswan_network }} -j ACCEPT\n-A FORWARD -s {{ openvpn_network }} -j ACCEPT/g" roles/common/templates/rules.v4.j2


#deploy algo
ansible-playbook main.yml --skip-tags debug -e "provider=local \
                              server=${SERVER_IP} \
                              endpoint=${SERVER_IP} \
                              server_name=algo \
                              ondemand_cellular=false \
                              ondemand_wifi=false \
                              openvpn_network='10.19.50.0/24' \
                              dns_adblocking=false \
                              ssh_tunneling=false \
                              store_pki=true \
                              ondemand_wifi_exclude='' \
                              ondemand_cellular=true \
                              ssh_user=ubuntu \
                              ansible_port=22 \
                              ansible_ssh_private_key_file=../private_key.txt"

#deploy netdata, openvpn
cd ../ansible
ansible-galaxy install -r requirements.yml -p roles

ansible-playbook -i ${SERVER_IP}, netdata.yml -e "ansible_user=ubuntu ansible_port=22
                              ansible_ssh_private_key_file=../private_key.txt"

ansible-playbook -i ${SERVER_IP}, openvpn.yml -e "ansible_user=ubuntu ansible_port=22
                              ansible_ssh_private_key_file=../private_key.txt
                              openvpn_ca_path=/etc/ipsec.d/cacerts/ca.crt
                              openvpn_cert_path=/etc/ipsec.d/certs/${SERVER_IP}.crt
                              openvpn_key_path=/etc/ipsec.d/private/${SERVER_IP}.key
                              openvpn_dh_path=/etc/openvpn/server/dh.pem
                              openvpn_radius_enabled=false openvpn_generate_certs=false
                              openvpn_client_ip_subnet_long='10.19.50.0 255.255.255.0'"

ansible-playbook -i localhost, openvpn-config.yml -e "ansible_connection=local server=${SERVER_IP}"


#### Upload confgi artifacts to backend
cd ..

base64 -w 0 algo/configs/${SERVER_IP}/ipsec/.pki/private/phone_ca.p12 > algo/configs/${SERVER_IP}/ipsec/.pki/private/phone_ca.p12.b64
cat algo/configs/${SERVER_IP}/.config.yml | grep p12 | awk '{print $2}' | sed "s/'//g" > p12pw 

for file in ansible/ovpn.conf algo/configs/${SERVER_IP}/ipsec/apple/phone.mobileconfig\
            algo/configs/${SERVER_IP}/wireguard/phone.png algo/configs/${SERVER_IP}/wireguard/apple/ios/phone.mobileconfig\
            algo/configs/${SERVER_IP}/wireguard/apple/macos/phone.mobileconfig private_key.txt\
            algo/configs/${SERVER_IP}/ipsec/manual/cacert.pem algo/configs/${SERVER_IP}/ipsec/.pki/private/phone_ca.p12.b64\
            p12pw algo/configs/${SERVER_IP}/ipsec/manual/phone.conf; do
    size=$( stat --printf="%s" $file )
    if [[ $? -ne "0" ]]; then
      echo "$file not found"
      exit 1
    fi
    if [[ $size -eq "0" ]]; then
      echo "$file is empty"
      exit 1
    fi
done

# upload OpenVPN config
curl -X POST  -H 'Content-Type: application/xml' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @ansible/ovpn.conf {$ .ConfigCallback $}/openvpn.ovpn

# upload iOS mobile config via backend callback
curl -X POST  -H 'Content-Type: application/xml' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/ipsec/apple/phone.mobileconfig {$ .ConfigCallback $}/ios/ikev2.mobileconfig

# upload WireGuard
curl -X POST  -H 'Content-Type: image/png' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/wireguard/phone.png {$ .ConfigCallback $}/wireguard.png
curl -X POST  -H 'Content-Type: text/plain' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/wireguard/apple/ios/phone.mobileconfig {$ .ConfigCallback $}/ios/wireguard.mobileconfig
curl -X POST  -H 'Content-Type: text/plain' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/wireguard/apple/macos/phone.mobileconfig {$ .ConfigCallback $}/macos/wireguard.mobileconfig

# upload ssh private key
curl -X POST  -H 'Content-Type: text/plain' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @private_key.txt {$ .ConfigCallback $}/ssh.txt

# upload IPSec manual configs
curl -X POST  -H 'Content-Type: application/x-pem-file' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/ipsec/manual/cacert.pem {$ .ConfigCallback $}/ipsec/cacert.pem

curl -X POST  -H 'Content-Type: application/x-pkcs12' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/ipsec/.pki/private/phone_ca.p12.b64 {$ .ConfigCallback $}/ipsec/p12.p12
curl -X POST  -H 'Content-Type: text/plain' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @p12pw {$ .ConfigCallback $}/ipsec/p12pw.txt

#
curl -X POST  -H 'Content-Type: text/plain' -H 'X-INTERNAL-AUTH:{$ .AuthToken $}' --data-binary @algo/configs/${SERVER_IP}/ipsec/manual/phone.conf {$ .ConfigCallback $}/ipsec/sswanconfig.conf
