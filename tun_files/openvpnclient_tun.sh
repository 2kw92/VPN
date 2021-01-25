yum install epel-release -y
yum install openvpn mc wget bridge-utils net-tools -y
cp /vagrant/ca.crt /etc/openvpn/client/ca.crt
cp /vagrant/tun_files/client.conf /etc/openvpn/client/client.conf
cp /vagrant/openvpnclient.crt /etc/openvpn/client/openvpnclient.crt
cp /vagrant/openvpnclient.key /etc/openvpn/client/openvpnclient.key
mkdir /var/log/openvpn
systemctl start openvpn-client@client.service
systemctl enable openvpn-client@client.service