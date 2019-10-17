---
title: 搭建本地私有云之时钟对准NTP
categories:
  - Tech
tags:
  - on-premise-cloud
  - ntp
date: 2019-10-17 11:16:43
---

这个系列是笔者在为实验室搭建本地私有云的过程中所记载的笔记,看起来会比较杂乱 :)

在搭建本地私有云的过程中,保证所有系统之间的时钟同步是非常重要的,因此为本地私有云维护一个专门的NTP server也是非常有必要的

<!-- more -->

## 搭建NTP服务

###  安装NTP

    ```console
    sudo apt install ntp
    ```
    
###  修改ntp server虚拟主机的配置文件

    ```console
    sudo vim /etc/ntp.conf
    -----------------------
    restrict -4 default notrap nomodify nopeer
    restrict -6 default notrap nomodify nopeer

    restrict 127.0.0.1
    restrict ::1

    driftfile /var/lib/ntp/drift/ntp.drift # path for drift file

    logfile   /var/log/ntp		# alternate log file
    logconfig =syncall +clockall +sysevents

    keys /etc/ntp.keys		# path for keys file
    trustedkey 1			# define trusted keys
    requestkey 1			# key (7) for accessing server variables
    controlkey 1			# key (6) for accessing server variables

    restrict 0.cn.pool.ntp.org notrap nomodify noquery
    pool 0.cn.pool.ntp.org iburst minpoll 4 maxpoll 7
    restrict 1.cn.pool.ntp.org notrap nomodify noquery
    pool 1.cn.pool.ntp.org iburst minpoll 4 maxpoll 7
    restrict 2.cn.pool.ntp.org notrap nomodify noquery
    pool 2.cn.pool.ntp.org iburst minpoll 4 maxpoll 7
    restrict 3.cn.pool.ntp.org notrap nomodify noquery
    pool 3.cn.pool.ntp.org iburst minpoll 4 maxpoll 7

    server ntp.fudan.edu.cn iburst minpoll 4 maxpoll 7
    server time1.google.com iburst minpoll 4 maxpoll 7
    server time2.google.com iburst minpoll 4 maxpoll 7
    server time3.google.com iburst minpoll 4 maxpoll 7
    server time4.google.com iburst minpoll 4 maxpoll 7
    -----------------------
    ```

###  配置ntp服务

    ```console
    sudo systemctl enable ntp.service
    sudo systemctl start ntp.service
    # or
    sudo systemctl restart ntp.service
    ```

###  查看NTP时间对准情况

    > 重点关注offset和jitter两个参数,一般小于0.1就算校准了

    ```console
    watch -n 1 ntpq -pn
    -----------------------
    remote           refid              st  t   when poll   reach   delay   offset  jitter
    ======================================================================================
    *ntp.sonnyhcl. 23.71.59.65        3   u   18   32     377     0.364   -0.250   0.043
    ----------------------
    ```

## NTP客户端配置

当我们在本地私有云中新添加一个虚拟机,需要为它配置对应的ntp server时,以chrony为例我们需要做

```console
sudo vim /etc/chrony.conf
-------------------------
server ntp.sonnyhcl.top iburst minpoll 4 maxpoll 7
-------------------------
```
然后查看时钟对准情况
```
watch -n 1 ntpq -pn
```

