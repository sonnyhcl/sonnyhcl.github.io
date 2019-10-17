---
title: 搭建本地私有云之DHCP
categories:
  - Tech
tags:
  - on-premise-cloud
  - dhcp
date: 2019-10-17 12:35:11
---


这个系列是笔者在为实验室搭建本地私有云的过程中所记载的笔记,看起来会比较杂乱 :)

在搭建本地私有云时,双网口的配置意味着我们需要为两个网段分别配置IP规则,有必要为内网部署一个自动分配IP的dhcp服务.


<!-- more -->
当然,这一需求也可以由高级一点的交换机/路由器来完成,介于我们并没有交换机的预算,采用手动搭建dhcp服务器来解决

## Profile
我们的每台服务器上都有两个千兆网口,可以分别用来传输内部数据以及访问校园网

- 内网：静态地址 192.168.128.123/22
- 校园网：v4静态地址,由校园网分配. v6自动，可以连到ustc
- 本文的dhcpd 只为内网配置
```
$ cat /etc/netplan/01-netcfg.yaml 
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens3:
      dhcp4: no
      dhcp6: yes
      mtu: 8046
      addresses: [192.168.128.123/22]
      nameservers:
        search: [sonnyhcl.top]
        addresses: [192.168.128.121, 192.168.128.122]
#    ens5:
#      dhcp4: no
#      dhcp6: yes
#      addresses: [10.141.209.177/20]
#      gateway4: 10.141.208.1
```

- 网络配置常用命令
```
sudo netplan --debug apply
```

## 安装步骤
- 下载 dhcp 包
```
sudo apt install -y isc-dhcp-server
```

- 配置 /etc/default/isc-dhcp-server
```
# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpd's config file (default: /etc/dhcp/dhcpd.conf).
DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpd's PID file (default: /var/run/dhcpd.pid).
DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#	Don't use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#	Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACESv4="ens3"
INTERFACESv6=""
```

- 配置 /etc/dhcp/dhcpd.conf
```
# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#
# Attention: If /etc/ltsp/dhcpd.conf exists, that will be used as
# configuration file instead of this file.
#

# option definitions common to all supported networks...
option domain-name "sonnyhcl.top";
option domain-name-servers ipa.sonnyhcl.top, ipa02.sonnyhcl.top;

default-lease-time 14400;
max-lease-time 172800;

# The ddns-updates-style parameter controls whether or not the server will
# attempt to do a DNS update when a lease is confirmed. We default to the
# behavior of the version 2 packages ('none', since DHCP v2 didn't
# have support for DDNS.)
ddns-update-style interim;
ddns-updates on;
ddns-domainname "sonnyhcl.top";
ddns-rev-domainname "in-addr.arpa";

zone 168.192.in-addr.arpa. { primary ipa.sonnyhcl.top;  }

zone sonnyhcl.top. { primary ipa;}

subnet 192.168.128.0 netmask 255.255.252.0 {
  range 192.168.130.1 192.168.131.254;
  default-lease-time 14400;
  max-lease-time 172800;
  zone sonnyhcl.top. { primary 192.168.128.2; }
  zone in-addr.arpa. { primary 192.168.128.2; }
}



# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;
```

- 启动 dhcp
```
sudo systemctl enable isc-dhcp-server
sudo systemctl restart isc-dhcp-server
```
- 检查 dhcp 运行状况
```
$ ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8046 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:be:e4:86 brd ff:ff:ff:ff:ff:ff
    inet 192.168.128.123/22 brd 192.168.131.255 scope global noprefixroute ens3
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:febe:e486/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:7a:30:9f brd ff:ff:ff:ff:ff:ff
    inet6 2001:da8:8001:2303:79db:51e5:be9b:8f7a/64 scope global temporary dynamic 
       valid_lft 565778sec preferred_lft 47281sec
    inet6 2001:da8:8001:2303:e0cf:f5bd:b6b1:b7f1/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 2592000sec preferred_lft 604800sec
    inet6 fe80::4c49:2102:7423:e6ff/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

$ hostnamectl
   Static hostname: dhcp.sonnyhcl.top
         Icon name: computer-vm
           Chassis: vm
        Machine ID: e6811e2f509944c4adefc8176aaa406e
           Boot ID: 144f1851104644cfbd4275ae3450cdb4
    Virtualization: kvm
  Operating System: Ubuntu 18.04.2 LTS
            Kernel: Linux 4.15.0-50-generic
      Architecture: x86-64
      
$ systemd-resolve --status ens3
Link 2 (ens3)
      Current Scopes: DNS
       LLMNR setting: yes
MulticastDNS setting: no
      DNSSEC setting: no
    DNSSEC supported: no
         DNS Servers: 192.168.128.121
                      192.168.128.122
                      202.120.224.6
                      202.120.224.26
          DNS Domain: ~.
                      sonnyhcl.top

```