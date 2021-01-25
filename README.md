# VPN
ДЗ по теме VPN

Отличие tup от tun:        
Если нам нужно объединить две разные локальные сети в одну условно общую, но с разной адресацией,          
то нам нужен tun. В нашем случае мы объединяем две сети 192.168.1.0/29 и 192.168.2.0/29 для        
взаимного совместного доступа.

Если же стоит задача объединить 2 удаленные сети в единое адресное пространство, например сделать
единую сеть 192.168.1.0/29, то тогда бы мы использовали tap интерфейс и указали бы на компьютерах        
в обоих сетях не пересекающиеся адреса из одной подсети. То есть обе сети окажутся в одном широковещательном        
домене и смогут передавать данные с помощью широковещания на канальном уровне сетевой модели OSI.        
В таком состоянии openvpn работает в режиме моста.         

Для проверки tun разворачиваем Vagrantfile_tun      
Копируем нужный нам Vagrantfile в корневую директрию из директивы Vagrantfiles       
Переименовывам в  Vagrantfile и  запускаем       
Он поднимет стенд со всеми необходимыми настройками и сертификатами       
Заходим на сервер openvpnserver и там выполняем:         
```
[root@openvpnserver ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 83422sec preferred_lft 83422sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:e6:ef:57 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.1/29 brd 172.16.0.7 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fee6:ef57/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:61:29:1b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/29 brd 192.168.1.7 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe61:291b/64 scope link
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.0.0.1 peer 10.0.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::3496:8741:7de0:c6ae/64 scope link flags 800
       valid_lft forever preferred_lft forever
```        
Обращаем внимание на адреса туннеля vpn. Теперь проверяем статические маршруты:      
```
[root@openvpnserver ~]# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 100
10.0.0.0/24 via 10.0.0.2 dev tun0
10.0.0.2 dev tun0 proto kernel scope link src 10.0.0.1
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
172.16.0.0/29 dev eth1 proto kernel scope link src 172.16.0.1 metric 101
192.168.1.0/29 dev eth2 proto kernel scope link src 192.168.1.1 metric 102
192.168.2.0/29 via 10.0.0.2 dev tun0
```
Тут тоже все в порядке. Траффик для подсети филиала 192.168.2.0/29 будет маршрутизироваться в тоннель       

Проверим клиент заходим на него и провряем:         
```
[root@openvpnclient ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 83463sec preferred_lft 83463sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:d6:d9:9f brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.2/29 brd 172.16.0.7 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fed6:d99f/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:38:bc:a6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.1/29 brd 192.168.2.7 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe38:bca6/64 scope link
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.0.0.6 peer 10.0.0.5/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::6c2b:4cef:a107:2ae2/64 scope link flags 800
       valid_lft forever preferred_lft forever
```         
Ну и маршруты глянем заодно:       
```
[root@openvpnclient ~]# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 100
10.0.0.0/24 via 10.0.0.5 dev tun0
10.0.0.5 dev tun0 proto kernel scope link src 10.0.0.6
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
172.16.0.0/29 dev eth1 proto kernel scope link src 172.16.0.2 metric 101
192.168.1.0/29 via 10.0.0.5 dev tun0
192.168.2.0/29 dev eth2 proto kernel scope link src 192.168.2.1 metric 102
```
Все в порядке, подключение к vpn серверу есть, маршруты прописаны верно.        


Для проверки tap разворачиваем Vagrantfile_tap      
Копируем нужный нам Vagrantfile в корневую директрию из директивы Vagrantfiles       
Переименовывам в  Vagrantfile и  запускаем        
Он поднимет стенд со всеми необходимыми настройками и сертификатами     
Для организации tap-соединения мы воспользовались утилитой bridge-utils       
для того чтобы открыть необходимы мосты, использовали скрипт br.sh          
После поднятия необходимых мостов заходим на сервер openvpnserver и там выполняем:           
[root@openvpnserver ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85123sec preferred_lft 85123sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UP group default qlen 1000
    link/ether 08:00:27:e6:ef:57 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:fee6:ef57/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:61:29:1b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/29 brd 192.168.1.7 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe61:291b/64 scope link
       valid_lft forever preferred_lft forever
5: tap0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br0 state UP group default qlen 100
    link/ether 4e:00:92:b6:55:24 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::4c00:92ff:feb6:5524/64 scope link
       valid_lft forever preferred_lft forever
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:e6:ef:57 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.1/29 brd 172.16.1.7 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fee6:ef57/64 scope link
       valid_lft forever preferred_lft forever

Убеждаемся что все ок и tap режим доступен.        
После этого заходим на openvpnclient  и там проверяем:          
```
[root@openvpnclient openvpn]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 64480sec preferred_lft 64480sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:d6:d9:9f brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.2/29 brd 172.16.0.7 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fed6:d99f/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:38:bc:a6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.1/29 brd 192.168.2.7 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe38:bca6/64 scope link
       valid_lft forever preferred_lft forever
9: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/ether 3e:19:43:a6:0a:65 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.2/29 brd 172.16.0.7 scope global tap0
       valid_lft forever preferred_lft forever
    inet6 fe80::3c19:43ff:fea6:a65/64 scope link
       valid_lft forever preferred_lft forever
```       
```
[root@openvpnclient openvpn]# ip r
default via 10.0.2.2 dev eth0 proto dhcp metric 100
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
172.16.0.0/29 dev tap0 proto kernel scope link src 172.16.0.2
172.16.0.0/29 dev eth1 proto kernel scope link src 172.16.0.2 metric 101
192.168.2.0/29 dev eth2 proto kernel scope link src 192.168.2.1 metric 102
```        
Видим что все ок и tap режим доступен.        


Для того чтобы поднять RAS на базе OpenVPN мы испоьзуем тот же алгоритм        
чтои в первой части задания только нужно пробросить порт 1194 в виртуальную машину.        
Файл называется Vagrantfile_ras. После его поднятия поднимается сервер с необходимыми       
настройками. Так как и у меня клиент на Винде, то Скачиваем официальную версию бинарных файлов        
OpenVPN Community Edition с графическим интерфейсом управления.
И и ипортируем конфиг из репы ras_files/client.ovpn. После этого подключаемся и вот мой лог:         

```
Mon Jan 25 18:17:04 2021 OpenVPN 2.4.9 x86_64-w64-mingw32 [SSL (OpenSSL)] [LZO] [LZ4] [PKCS11] [AEAD] built on Apr 16 2020
Mon Jan 25 18:17:04 2021 Windows version 6.2 (Windows 8 or greater) 64bit
Mon Jan 25 18:17:04 2021 library versions: OpenSSL 1.1.1f  31 Mar 2020, LZO 2.10
Enter Management Password:
Mon Jan 25 18:17:04 2021 MANAGEMENT: TCP Socket listening on [AF_INET]127.0.0.1:25340
Mon Jan 25 18:17:04 2021 Need hold release from management interface, waiting...
Mon Jan 25 18:17:04 2021 MANAGEMENT: Client connected from [AF_INET]127.0.0.1:25340
Mon Jan 25 18:17:04 2021 MANAGEMENT: CMD 'state on'
Mon Jan 25 18:17:04 2021 MANAGEMENT: CMD 'log all on'
Mon Jan 25 18:17:04 2021 MANAGEMENT: CMD 'echo all on'
Mon Jan 25 18:17:04 2021 MANAGEMENT: CMD 'bytecount 5'
Mon Jan 25 18:17:04 2021 MANAGEMENT: CMD 'hold off'
Mon Jan 25 18:17:04 2021 MANAGEMENT: CMD 'hold release'
Mon Jan 25 18:17:04 2021 WARNING: No server certificate verification method has been enabled.  See http://openvpn.net/howto.html#mitm for more info.
Mon Jan 25 18:17:04 2021 TCP/UDP: Preserving recently used remote address: [AF_INET]127.0.0.1:1194
Mon Jan 25 18:17:04 2021 Socket Buffers: R=[65536->65536] S=[65536->65536]
Mon Jan 25 18:17:04 2021 Attempting to establish TCP connection with [AF_INET]127.0.0.1:1194 [nonblock]
Mon Jan 25 18:17:04 2021 MANAGEMENT: >STATE:1611587824,TCP_CONNECT,,,,,,
Mon Jan 25 18:17:04 2021 TCP connection established with [AF_INET]127.0.0.1:1194
Mon Jan 25 18:17:04 2021 TCP_CLIENT link local: (not bound)
Mon Jan 25 18:17:04 2021 TCP_CLIENT link remote: [AF_INET]127.0.0.1:1194
Mon Jan 25 18:17:04 2021 MANAGEMENT: >STATE:1611587824,WAIT,,,,,,
Mon Jan 25 18:17:04 2021 MANAGEMENT: >STATE:1611587824,AUTH,,,,,,
Mon Jan 25 18:17:04 2021 TLS: Initial packet from [AF_INET]127.0.0.1:1194, sid=18d8ae4a 8442d8bb
Mon Jan 25 18:17:04 2021 VERIFY OK: depth=1, CN=server
Mon Jan 25 18:17:04 2021 VERIFY OK: depth=0, CN=server
Mon Jan 25 18:17:04 2021 Control Channel: TLSv1.2, cipher TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384, 2048 bit RSA
Mon Jan 25 18:17:04 2021 [server] Peer Connection Initiated with [AF_INET]127.0.0.1:1194
Mon Jan 25 18:17:06 2021 MANAGEMENT: >STATE:1611587826,GET_CONFIG,,,,,,
Mon Jan 25 18:17:06 2021 SENT CONTROL [server]: 'PUSH_REQUEST' (status=1)
Mon Jan 25 18:17:06 2021 PUSH: Received control message: 'PUSH_REPLY,route 10.10.10.0 255.255.255.0,topology net30,ping 10,ping-restart 120,ifconfig 10.10.10.6 10.10.10.5,peer-id 0,cipher AES-256-GCM'
Mon Jan 25 18:17:06 2021 OPTIONS IMPORT: timers and/or timeouts modified
Mon Jan 25 18:17:06 2021 OPTIONS IMPORT: --ifconfig/up options modified
Mon Jan 25 18:17:06 2021 OPTIONS IMPORT: route options modified
Mon Jan 25 18:17:06 2021 OPTIONS IMPORT: peer-id set
Mon Jan 25 18:17:06 2021 OPTIONS IMPORT: adjusting link_mtu to 1627
Mon Jan 25 18:17:06 2021 OPTIONS IMPORT: data channel crypto options modified
Mon Jan 25 18:17:06 2021 Data Channel: using negotiated cipher 'AES-256-GCM'
Mon Jan 25 18:17:06 2021 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
Mon Jan 25 18:17:06 2021 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
Mon Jan 25 18:17:06 2021 interactive service msg_channel=964
Mon Jan 25 18:17:06 2021 ROUTE_GATEWAY 192.168.1.1/255.255.255.0 I=25 HWADDR=0c:dd:24:b2:56:6a
Mon Jan 25 18:17:06 2021 open_tun
Mon Jan 25 18:17:06 2021 TAP-WIN32 device [Подключение по локальной сети 2] opened: \\.\Global\{C745D690-649E-4931-A100-062D394CC0BE}.tap
Mon Jan 25 18:17:06 2021 TAP-Windows Driver Version 9.24 
Mon Jan 25 18:17:06 2021 Notified TAP-Windows driver to set a DHCP IP/netmask of 10.10.10.6/255.255.255.252 on interface {C745D690-649E-4931-A100-062D394CC0BE} [DHCP-serv: 10.10.10.5, lease-time: 31536000]
Mon Jan 25 18:17:06 2021 Successful ARP Flush on interface [22] {C745D690-649E-4931-A100-062D394CC0BE}
Mon Jan 25 18:17:06 2021 MANAGEMENT: >STATE:1611587826,ASSIGN_IP,,10.10.10.6,,,,
Mon Jan 25 18:17:11 2021 TEST ROUTES: 1/1 succeeded len=1 ret=1 a=0 u/d=up
Mon Jan 25 18:17:11 2021 MANAGEMENT: >STATE:1611587831,ADD_ROUTES,,,,,,
Mon Jan 25 18:17:11 2021 C:\WINDOWS\system32\route.exe ADD 10.10.10.0 MASK 255.255.255.0 10.10.10.5
Mon Jan 25 18:17:11 2021 Route addition via service succeeded
Mon Jan 25 18:17:11 2021 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
Mon Jan 25 18:17:11 2021 Initialization Sequence Completed
Mon Jan 25 18:17:11 2021 MANAGEMENT: >STATE:1611587831,CONNECTED,SUCCESS,10.10.10.6,127.0.0.1,1194,127.0.0.1,57472
```

На этом дз закончено