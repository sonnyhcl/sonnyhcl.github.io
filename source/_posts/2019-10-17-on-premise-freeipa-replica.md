---
title: 搭建本地私有云之FreeIPA主从备份
categories:
  - Tech
tags:
  - on-premise-cloud
  - FreeIPA
  - FreeIPA replica
date: 2019-10-17 13:04:09
updated: 2019-10-17 13:04:09
---

这个系列是笔者在为实验室搭建本地私有云的过程中所记载的笔记,看起来会比较杂乱 :)

为了保证FreeIPA服务的稳定性,我们需要为它添加一个replica作为主从备份.

<!-- more -->
# Centos7 安装 FreeIPA Replica
> centos7 + 4vCPU + 4G

## Profile

-  ip: 192.168.128.122/22
-  hostname: ipa02.sonnyhcl.top
-  kerberos realm: SONNYHCL.TOP
-  dns domain: sonnyhcl.top
-  admin server: ipa.sonnyhcl.top
-  with DNS: yes
-  forwarder: 127.0.0.1, 202.120.224.6, 202.120.224.26

## 安装步骤
### 设置 ipa02 的 DNS 记录
```
选择: 网络服务 -> DNS 区域
添加一个 192.168.128.0/22 的反向区域 128.168.192.in-addr.arpa.
点击 DNS 区域的 sonnyhcl.top. 进去这个子域内
增加一条 ipa02.sonnyhcl.top 的 A 记录，并且在 Create reverse 打勾，添加 IP 地址的反向记录
```

### 配置机器名 hostname
```
sudo hostnamectl set-hostname ipa02.sonnyhcl.top
# hostname -f 查看
```

### 验证域名解析

配置 ipa02 dns 为 192.168.128.121　然后验证正反解
```
dig +short ipa02.sonnyhcl.top A
dig +short -x 192.168.128.122
```

### 配置 /etc/hosts
```
echo "192.168.128.121 ipa.sonnyhcl.top ipa" | sudo tee -a /etc/hosts
echo "192.168.128.122 ipa02.sonnyhcl.top ipa02" | sudo tee -a /etc/hosts
```

### 安装 FreeIPA Client
```
sudo yum install ipa-client
sudo ipa-client-install --mkhomedir --enable-dns-updates --server ipa.sonnyhcl.top --domain sonnyhcl.top --realm SONNYHCL.TOP --hostname ipa02.sonnyhcl.top
```

### 配置防火墙
```
sudo firewall-cmd --permanent --add-service={ntp,http,https,ldap,ldaps,kerberos,kpasswd,dns}
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

### 安装 FreeIPA Replica
```
sudo yum install ipa-server ipa-server-dns
sudo ipa-replica-install
```

### 安装 FreeIPA CA Replica
```
sudo ipa-ca-install
```

### 安装 FreeIPA DNS Replica
```
sudo ipa-dns-install
```

### 检查所有服务运行状态
```
sudo ipactl status
```
```
Directory Service: RUNNING
krb5kdc Service: RUNNING
kadmin Service: RUNNING
named Service: RUNNING
httpd Service: RUNNING
ipa-custodia Service: RUNNING
ntpd Service: RUNNING
pki-tomcatd Service: RUNNING
ipa-otpd Service: RUNNING
ipa-dnskeysyncd Service: RUNNING
ipa: INFO: The ipactl command was successful
```


## 参考链接
- [CentOS 7 安装 FreeIPA 主从复制](https://qizhanming.com/blog/2019/04/29/install-freeipa-server-and-replica-on-centos-7)
- [How to Configure FreeIPA replication on Ubuntu / CentOS](https://computingforgeeks.com/how-to-configure-freeipa-replication-on-ubuntu-centos/)

