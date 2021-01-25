# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
:openvpnserver => {
        :box_name => "centos/7"
}  
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
        SHELL
        box.vm.provision "shell", path: "ras_files/openvpnserver.sh"
        
        case boxname.to_s
        when "openvpnserver"
        box.vm.network "forwarded_port", guest: 1194, host: 1194, host_ip: "127.0.0.1"
        end

      end

  end
  
  
end