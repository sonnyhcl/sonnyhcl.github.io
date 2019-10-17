---
title: 搭建本地私有云之域控认证FreeIPA
categories:
  - Tech
tags:
  - Tech
date: 2019-10-17 11:29:04
---

当我们搭建本地私有云的时候,首先要考虑的就是一套统一的用户认证管理系统.

市场上常用的用户管理有这么几种
1. 可以选择手动搭建LDAP服务并自己进行管理,这是最为复杂的操作
2. 选择一套较完善的开源方案,例如我们这里选用的FreeIPA,集成了认证/域控/用户管理等多种功能
3. 选择使用Active Directory,除了收费之外一切都是顶配,不折腾省心

<!-- more -->
FreeIPA官方目前对`RedHat~Centos~Fedora>Ubuntu~Debian`几家做的兼容性比较多,这里记录了Centos和Ubuntu上安装ipa server的过程。

## Centos7 安装 FreeIPA Server
> Centos + 4vCPU + 4G

### Profile
-  ip: 192.168.128.121
-  kerberos realm: SONNYHCL.TOP
-  dns domain: sonnyhcl.top
-  admin server: ipa.sonnyhcl.top
-  with DNS: yes
-  forwarder: 127.0.0.1, 202.120.224.6, 202.120.224.26

### 步骤
1. 配置机器名 hostname
```
$ sudo hostnamectl set-hostname ipa.sonnyhcl.top
$ hostname -f
ipa.sonnyhcl.top
```

2. 配置 /etc/hosts
```
# <ip fqdn shortname>
$ echo "192.168.128.121 ipa.sonnyhcl.top ipa" |  sudo tee -a /etc/hosts
```

3. 配置随机数硬件加速
```
$ sudo yum update -y
$ sudo yum install rng-tools
$ sudo systemctl enable rngd
$ sudo systemctl status rngd
```

4. 下载 FreeIPA-Server
```
$ sudo yum install -y ipa-server ipa-server-dns
```

5. 配置 FreeIPA-Server
```
$ sudo ipa-server-install --allow-zone-overlap
```

接下来要输入参数如下
```
- Do you want to configure integrated DNS (BIND)? [no]: yes
- Server host name [ipa.sonnyhcl.top]: <Enter>
- Please confirm the domain name [sonnyhcl.top]: <Enter>
- Please provide a realm name [SONNYHCL.TOP]: <Enter>
- Directory Manager password: <secure password>
- Password (confirm): <secure password>
- IPA admin password: <secure password>
- Password (confirm): <secure password>
```

6. 配置 authconfig
```
$ sudo authconfig --enablemkhomedir --update
```

7. 开启防火墙
```
$ sudo firewall-cmd --permanent --add-service={ntp,http,https,ldap,ldaps,kerberos,kpasswd,dns}
$ sudo firewall-cmd --reload
$ sudo firewall-cmd --list-all
```

### 测试

1. 测试 kerberos
```
$ kinit admin
Password for admin@SONNYHCL.TOP:
$ klist
Ticket cache: KEYRING:persistent:0:0
Default principal: admin@SONNYHCL.TOP

Valid starting     Expires            Service principal
06/29/18 22:52:40  06/30/18 22:52:36  krbtgt/SONNYHCL.TOP@SONNYHCL.TOP
```

2. 测试 ipa
```
$ ipa user-find admin
--------------
1 user matched
--------------

  User login: admin
  Last name: Administrator
  Home directory: /home/admin
  Login shell: /bin/bash
  Principal alias: admin@COMPUTINGFORGEEKS.COM
  UID: 1506000000
  GID: 1506000000
  Account disabled: False
  ----------------------------
  Number of entries returned 1
  ----------------------------
$ sudo ipactl status
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

3. 测试 Web UI

如果在虚拟机中部署，在宿主机访问，请确保你的宿主机　hosts　里面也写入了第2步中的域名解析


访问`https://ipa.sonnyhcl.top/ipa/ui`，选择　高级　->　继续访问　即可跳过浏览器对 https 证书的质疑。输入刚刚创建的`admin`账户密码即可进入 Web 管理界面。

### 参考链接
- [CentOS 7 安装 FreeIPA 主从复制](https://qizhanming.com/blog/2019/04/29/install-freeipa-server-and-replica-on-centos-7)
- [https://computingforgeeks.com/how-to-install-and-configure-freeipa-server-on-ubuntu-18-04-ubuntu-16-04/](https://computingforgeeks.com/how-to-install-and-configure-freeipa-server-on-ubuntu-18-04-ubuntu-16-04/)

## Ubuntu18 安装 FreeIPA Server
> Ubuntu18 + 4vCPU + 4G

### Profile
-  ip: 192.168.128.121
-  kerberos realm: SONNYHCL.TOP
-  dns domain: sonnyhcl.top
-  admin server: ipa.sonnyhcl.top
-  with DNS: yes
-  forwarder: 127.0.0.1, 202.120.224.6, 202.120.224.26

### 步骤
1. 配置机器名 hostname
```
$ sudo hostnamectl set-hostname ipa.sonnyhcl.top
$ hostname -f
ipa.sonnyhcl.top
```

2. 配置 /etc/hosts
```
# <ip fqdn shortname>
$ echo "192.168.128.121 ipa.sonnyhcl.top ipa" |  sudo tee -a /etc/hosts
```

3. 配置随机数硬件加速
```
$ sudo apt update -y
$ sudo apt install rng-tools
$ echo "HRNGDEVICE=/dev/urandom" | sudo tee -a /etc/defaults/rng-tools
$ sudo systemctl enable rng-tools
$ sudo systemctl start rng-tools
```

4. 下载 FreeIPA-Server
```
$ sudo apt install -y freeipa-server
```
安装过程中会依次让你输入之前 Profile 中定义的三个参数
```
-  kerberos realm: SONNYHCL.TOP
-  dns domain: sonnyhcl.top
-  admin server: ipa.sonnyhcl.top
```

5. 配置 FreeIPA-Server
```
$ sudo ipa-server-install --allow-zone-overlap
# 接下来要输入参数如下
- Do you want to configure integrated DNS (BIND)? [no]: yes
- Server host name [ipa.sonnyhcl.top]: <Enter>
- Please confirm the domain name [sonnyhcl.top]: <Enter>
- Please provide a realm name [SONNYHCL.TOP]: <Enter>
- Directory Manager password: <secure password>
- Password (confirm): <secure password>
- IPA admin password: <secure password>
- Password (confirm): <secure password>
```

> 详细安装记录见附录

6. Ubuntu Patch

> 这几个都是FreeIPA在ubuntu上遇到的兼容性问题的修补方法

```
$ sudo touch /etc/krb5kdc/kadm5.acl
$ sudo chmod +x /var/lib/krb5kdc
$ echo "session optional pam_mkhomedir.so" | sudo tee -a /etc/pam.d/common-session
$ sudo pam-auth-update
# 选 create home dir when first login
```

### 测试

1. 测试 kerberos
```
$ kinit admin
Password for admin@SONNYHCL.TOP:
$ klist
Ticket cache: KEYRING:persistent:0:0
Default principal: admin@SONNYHCL.TOP

Valid starting     Expires            Service principal
06/29/18 22:52:40  06/30/18 22:52:36  krbtgt/SONNYHCL.TOP@SONNYHCL.TOP
```

2. 测试 ipa
```
$ ipa user-find admin
--------------
1 user matched
--------------

  User login: admin
  Last name: Administrator
  Home directory: /home/admin
  Login shell: /bin/bash
  Principal alias: admin@COMPUTINGFORGEEKS.COM
  UID: 1506000000
  GID: 1506000000
  Account disabled: False
  ----------------------------
  Number of entries returned 1
  ----------------------------
$ sudo ipactl status
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

3. 测试 Web UI

如果在虚拟机中部署，在宿主机访问，请确保你的宿主机　hosts　里面也写入了第2步中的域名解析

访问`https://ipa.soaringlao.top/ipa/ui`，选择　高级　->　继续访问　即可跳过浏览器对 https 证书的质疑。输入刚刚创建的`admin`账户密码即可进入 Web 管理界面。

### 参考链接
- [CentOS 7 安装 FreeIPA 主从复制](https://qizhanming.com/blog/2019/04/29/install-freeipa-server-and-replica-on-centos-7)
- [https://computingforgeeks.com/how-to-install-and-configure-freeipa-server-on-ubuntu-18-04-ubuntu-16-04/](https://computingforgeeks.com/how-to-install-and-configure-freeipa-server-on-ubuntu-18-04-ubuntu-16-04/)
- 
- [FreeIPA ansible](https://github.com/freeipa/ansible-freeipa)

## 附录
```
To accept the default options shown in square brackets, just press Enter key

Do you want to configure integrated DNS (BIND)? [no]: yes

Enter the fully qualified domain name of the computer

on which you're setting up server software. Using the form

<hostname>.<domainname>

Example: master.example.com.

Server host name [ipa.sonnyhcl.top]: <Enter>
The domain name has been determined based on the host name.
Please confirm the domain name [sonnyhcl.top]: <Enter>
The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.
Please provide a realm name [SONNYHCL.TOP]: <Enter>
Certain directory server operations require an administrative user.
This user is referred to as the Directory Manager and has full access
to the Directory for system management tasks and will be added to the
instance of directory server created for IPA.
The password must be at least 8 characters long
Directory Manager password: <secure password>
Password (confirm): <secure password>
The IPA server requires an administrative user, named 'admin'.
This user is a regular system account used for IPA server administration.

IPA admin password: <secure password>
Password (confirm): <secure password>

The IPA Master Server will be configured with:

Hostname:    ipa.sonnyhcl.top
IP address(es): 192.168.128.121
Domain name: sonnyhcl.top
Realm name:  SONNYHCL.TOP

The CA will be configured with:

Subject DN:   CN=Certificate Authority,O=SONNYHCL.TOP
Subject base: O=SONNYHCL.TOP
Chaining:  self-signed


Continue to configure the system with these values? [no]: yes

...output cut...
Client configuration complete.

The ipa-client-install command was successful

Setup complete

Next steps:

1. You must make sure these network ports are open: 
    TCP Ports: 
    * 80, 443: HTTP/HTTPS 
    * 389, 636: LDAP/LDAPS 
    * 88, 464: kerberos UDP Ports: 
    * 88, 464: kerberos 
    * 123: ntp 
2. You can now obtain a kerberos ticket using the command: 'kinit admin' 
This ticket will allow you to use the IPA tools (e.g., ipa user-add) and the web user interface.
```
