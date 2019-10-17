---
title: 本地云构建之NTP服务
categories:
  - Tech
tags:
  - Tech
date: 2019-10-17 11:16:43
---

# 时钟对准
在搭建本地私有云的过程中,保证所有系统之间的时钟同步是非常重要的,因此为本地私有云维护一个专门的NTP server也是非常有必要的

<!-- more -->

## NTP server

1.  安装NTP

    ```console
    sudo apt install ntp
    ```
    
2.  修改ntp server虚拟主机的NTP配置文件

    ```console
    sudo vim /etc/ntp.conf
    -----------------------
    #pool 0.ubuntu.pool.ntp.org iburst
    #pool 1.ubuntu.pool.ntp.org iburst
    #pool 2.ubuntu.pool.ntp.org iburst
    #pool 3.ubuntu.pool.ntp.org iburst
    server ntp.sonnyhcl.top iburst maxpoll 7 minpoll 4

    # Use Ubuntu's ntp server as a fallback.
    #pool ntp.ubuntu.com
    -----------------------
    ```

3.  配置ntp服务

    ```console
    sudo systemctl enable ntp.service
    sudo systemctl start ntp.service
    # or
    sudo systemctl restart ntp.service
    ```

4.  查看NTP时间对准情况

    > 重点关注offset和jitter两个参数,一般小于0.1就算校准了

    ```console
    watch -n 1 ntpq -pn
    -----------------------
    remote           refid              st  t   when poll   reach   delay   offset  jitter
    ======================================================================================
    *ntp.sonnyhcl. 23.71.59.65        3   u   18   32     377     0.364   -0.250   0.043
    ----------------------
    ```

## 虚拟主机配置

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

