yum install epel-release -y
yum install openvpn mc wget bridge-utils net-tools -y
# Генерим необхрдимые сертификаты
#cd /etc/openvpn/keys
#wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
#tar xzvf EasyRSA-3.0.8.tgz && mv EasyRSA-3.0.8 easyrsa && rm -f EasyRSA-3.0.8.tgz
#cd /etc/openvpn/keys/easyrsa
#mv vars.example vars
#./easyrsa init-pki
#./easyrsa build-ca
#./easyrsa gen-req server nopass
#./easyrsa sign-req server server
#./easyrsa gen-dh
cp /vagrant/ca.crt /etc/openvpn/server/ca.crt
cp /vagrant/dh.pem /etc/openvpn/server/dh.pem
cp /vagrant/server.crt /etc/openvpn/server/server.crt
cp /vagrant/server.key /etc/openvpn/server/server.key
#./easyrsa build-client-full openvpnclient nopass
mkdir /etc/openvpn/ccd && mkdir /var/log/openvpn
cp /vagrant/tap_files/server.conf /etc/openvpn/server/server.conf
cp /vagrant/openvpnclient /etc/openvpn/ccd/openvpnclient
setenforce 0
cd /vagrant/tap_files
./br.sh
systemctl start openvpn-server@server.service
systemctl enable openvpn-server@server.service