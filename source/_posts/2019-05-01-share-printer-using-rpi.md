---
title: 使用树莓派搭建无线打印机
date: 2019-05-01 19:10:41
categories:
- Tech
tags: 
- "Raspberry"
- "RPI"
- "HypriotOS"
- "Printer"
---

办公室里的打印机的网口莫名其妙地坏掉了，只剩下USB打印还能用。总不能打印什么都端电脑过去打印机那边打吧，这时候就需要一个树莓派，来干点共享网络打印机的功能了。

<!-- more -->

## 物品准备
- 一个树莓派，2代3代都可以
- 一张至少16GB的TF卡
- 一个TF读卡器
- 一根网线
- 一个可以（或者是只能）通过USB打印的打印机

## 树莓派系统安装

区别于官方提供的镜像版本，我们将会采用一个专门给树莓派定制的镜像版本`Hypriot`。它在镜像内预先安装了armhf版本的docker，并且采用cloud-init在烧写的时候来初始化初始配置。用cloud-init有多爽呢，一般情况下我们得至少有个键鼠套装+显示屏才能完成树莓派的初步网络配置，而现在只需要在烧录镜像的时候指定userdata就可以完成初步的网络配置、用户管理等。

- [Hypriot镜像下载地址](http://blog.hypriot.com/downloads/)
- [命令行烧录工具flash](https://github.com/hypriot/flash)

本文所有操作除了在树莓派上，其它均在`ubuntu 16.04`下进行操作

### 树莓派系统镜像
```
wget https://github.com/hypriot/image-builder-rpi/releases/download/v1.10.0/hypriotos-rpi-v1.10.0.img.zip
```

### 烧录工具flash
```
sudo apt-get install -y pv curl python-pip unzip hdparm
git clone https://github.com/hypriot/flash
cd flash
chmod +x flash
sudo cp flash /usr/local/bin/flash
```

### 自定义烧录参数
烧录tf卡之前，首先需要定制一下cloud-init要用到的userdata文件。flash本身有提供几个sample模板，包含事先预置ssh公钥、配置静态ip、配置wifi连接密码等多种花式操作。这是我用来配置静态IP的模板，你可以根据自己需要修改当中的静态IP。
> sample/static.yml

```yaml
#cloud-config
# vim: syntax=yaml
#

# Set your hostname here, the manage_etc_hosts will update the hosts file entries as well
hostname: printer
manage_etc_hosts: true
# don't write debian.org into apt mirrors
apt_preserve_sources_list: true

# You could modify this for your own user information
users:
  - name: pirate
    gecos: "Hypriot Pirate"
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: users,docker,video
    plain_text_passwd: hypriot
    lock_passwd: false
    ssh_pwauth: true
    chpasswd: { expire: false }
    ssh-authorized-keys:
      - ssh-rsa AAAA....NN   # insert your SSH public key ~/.ssh/id_rsa.pub here

package_upgrade: false

# Static IP address
write_files:
  - content: |
      persistent
      # Generate Stable Private IPv6 Addresses instead of hardware based ones
      slaac private

      # static IP configuration:
      interface eth0
      static ip_address=10.xxx.245.130/23
      static routers=10.xxx.244.1
      static domain_name_servers=202.120.224.6

    path: /etc/dhcpcd.conf

# These commands will be ran once on first boot only
runcmd:
  # Pickup the hostname changes
  - 'systemctl restart avahi-daemon'
```

### 烧录TF卡
可以使用`sudo fdisk -l`或者`df -hT`命令查看待烧录的TF卡的盘符，这里假设它为`/dev/sdx`。
```
flash --userdata sample/static.yml -d /dev/sdx hypriotos-rpi-v1.10.0.img.zip
```

烧录完就可以直接通过ssh直接连接到树莓派上
```
clhu@t5 ~> ssh pirate@10.xxx.245.130
Linux pi 4.14.98-v7+ #1200 SMP Tue Feb 12 20:27:48 GMT 2019 armv7l

HypriotOS (Debian GNU/Linux 9)

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Wed May  1 16:01:55 2019 from 10.131.245.147
HypriotOS/armv7: pirate@printer in ~
$ 
```

## CUPS开启共享打印机
> 接下来在树莓派上进行操作

### 树莓派镜像源配置
在安装软件包之前，首先需要配置一下对应的镜像源，这里主要[参考tuna的镜像源配置方法](https://mirrors.tuna.tsinghua.edu.cn/help/raspbian/)。

- 编辑 `/etc/apt/sources.list` 文件，删除原文件所有内容，用以下内容取代：

```
deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ stretch main non-free contrib
deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ stretch main non-free contrib
```
- 编辑 `/etc/apt/sources.list.d/raspi.list` 文件，删除原文件所有内容，用以下内容取代：

```
deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ stretch main
```

### 树莓派安装CUPS
```
sudo apt update
sudo apt install cups
sudo service cups start
sudo usermod -a -G lpadmin pirate
sudo cupsctl --remote-any
```

### CUPS服务配置
cups服务启动之后，我们就可以通过网页来对cups服务进行配置，类似于[https://10.xxx.245.130:631]()，如下图所示。

![cups](cups.png)

依次点击其中的`Administration -> Add Printer`页面，会让你输一下管理员密码，保证接下来的操作有足够权限。
接下来只需要一路continue即可，需要注意的是Sharing一定要记得勾选。

![sharing](sharing.png)

## 打印机使用
在笔者所用的Ubuntu中，只需要打开打印机设置页面，点击`+`按钮来添加一个打印机。这时候只需要输入打印机的IP地址，就可以看到打印机列表中出现了我们通过树莓派共享的网络打印机。

![linux](linux.png)

## 参考链接
- [使用树莓派搭建无线打印机](https://www.jianshu.com/p/d3752c584e01)
- [如何正确地用树莓派共享打印机](https://sspai.com/post/40997)