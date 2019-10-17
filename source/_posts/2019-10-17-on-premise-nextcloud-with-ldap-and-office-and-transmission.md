---
title: 搭建本地私有云之集成LDAP+Office+Transmission的NextCloud
categories:
  - Tech
tags:
  - on-premise-cloud
  - NextCloud
  - onlyoffice
  - transmission
date: 2019-10-17 13:30:41
---
这个系列是笔者在为实验室搭建本地私有云的过程中所记载的笔记,看起来会比较杂乱 :)


NextCloud可以用来搭建个人网盘,同时还可以纳入LDAP认证进行统一的用户管理.在此基础之上为了进一步增添办公属性,我们还为它集成了onlyoffice办公套件的支持以及transmission下载套件的支持.

<!-- more -->

首先我们需要一台崭新的ubuntu18.04的虚拟机,虚拟机的初始化配置此处不再赘述.我们为该虚拟机新增一块500GB的数据盘用作数据存储.

## 搭建nextcloud服务

### 挂载数据盘
```
sudo mkfs.ext4 /dev/vdb
echo "/dev/vdb	/srv	ext4	defaults 	0	0" | sudo tee -a /etc/fstab
sudo mount /dev/vdb /srv
sudo chown -R oem:oem /srv
lsblk
```

### 安装docker和docker-compose
```
sudo apt install docker.io docker-compose
sudo usermod -aG docker oem
sudo systemctl enable docker
```

### 准备db.env和docker-compose.yml
```
mkdir /srv/compose
cd /srv/compose
oem@nextcloud:/srv/compose$ tree -L 2
.
├── certs
│   ├── nextcloud.sonnyhcl.top.crt
│   └── nextcloud.sonnyhcl.top.key
├── db.env
└── docker-compose.yml

1 directory, 4 files
```


### `/srv/compose/db.env`
```
MYSQL_PASSWORD=nextcloud
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
```

### `/srv/compose/docker-compose.yml`
```
version: '3'

services:
  db:
    image: mariadb
    restart: unless-stopped
    container_name: mariadb
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    volumes:
      - /srv/db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=nextcloud
    env_file:
      - db.env

  nextcloud:
    image: nextcloud
    restart: unless-stopped
    container_name: nextcloud
    environment:
      - TZ=Asia/Shanghai
      - NEXTCLOUD_ADMIN_USER=oem            
      - NEXTCLOUD_ADMIN_PASSWORD=oem
      - NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.sonnyhcl.top
      - MYSQL_HOST=db
      - VIRTUAL_HOST=nextcloud.sonnyhcl.top
    env_file:
      - db.env
    volumes:
      - /srv/nextcloud:/var/www/html
    depends_on:
      - db

  nginx:
    image: jwilder/nginx-proxy
    restart: unless-stopped
    container_name: nginx
    environment:
      - VIRTUAL_PROTO=https
      - VIRTUAL_PORT=443
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs
```

### 启动nextcloud服务
```
docker-compose up -d
```


### 参考链接
- [nginx ssl](https://github.com/jwilder/nginx-proxy#ssl-backends)
- [nextcloud docker-compose example](https://github.com/nextcloud/docker/blob/master/.examples/docker-compose/with-nginx-proxy-self-signed-ssl/mariadb/fpm/docker-compose.yml)


## 整合Nextcloud与LDAP/AD
### 准备工作
- 登录`https://nextcloud.sonnyhcl.top`
- 选择启动LDAP插件
- 进入 设置页面 -> LDAP/AD整合

### 配置LDAP

#### 服务器标签页
这里用admin账号应该不是best practice 
```
Server: ldap://ipa.sonnyhcl.top
Port: 389
User DN: uid=admin,cn=users,cn=accounts,dc=sonnyhcl,dc=top
Password: xxx
BaseCN: dc=sonnyhcl,dc=top
```

#### 用户标签页
手动编辑LDAP查询
```
 Edit raw filter instead: (objectclass=*)
```
验证设置和统计用户应该能发现若干个用户

#### 登录属性标签页
```
LDAP Username: checked
Edit raw filter instead: (&(objectclass=*)(uid=%uid))
```
- 验证设置，输入clhu返回找到用户

#### 群组标签页
```
Edit raw filter instead: (|(cn=ipausers))
```
- 验证设置和统计分组数应该返回1

#### 高级标签页
##### 连接设置
```
Configuration Active: checked
```

##### 目录设置
```
 User Display Name Field: displayname
 Base User Tree: cn=users,cn=accounts,dc=sonnyhcl,dc=top
 Group Display Name Field: cn
 Base Group Tree: cn=groups,cn=accounts,dc=sonnyhcl,dc=top
 Group-Member association: uniqueMember
 Paging chunksize: 500
 ```

##### 特殊属性
```
Email Field: mail
User Home Folder Naming Rule: cn
```

#### 专家标签页
```
Internal Username Attrbute: uid
```

### 参考链接
- [Owncloud_Authentication_against_FreeIPA](https://www.freeipa.org/page/Owncloud_Authentication_against_FreeIPA)


## 使用Transmission实现PT下载

### 安装transmission
#### 安装包
```
sudo apt install transmission-daemon -y
```
#### 修改配置
```
# 必须先暂停daemon才能修改配置文件，否则分分钟被daemon覆写
sudo service transmission-daemon stop
sudo vim /etc/transmission-daemon/settings.json
-------------------
#更改以下参数的值
#默认下载位置
"download-dir": "/srv/downloads"
#替换为远程连接的用户名和密码
"rpc-password":"nextcloud"
"rpc-username": "nextcloud"
#关闭远程连接白名单
"rpc-whitelist-enabled": false
#限速20M/s
"speed-limit-down": 20000
"speed-limit-down-enabled": true
-------------------
sudo service transmission-daemon start
```
#### 打开`ip:port`，输入用户名密码访问web下载页面

### 在Nextcloud中集成
- 修改nextcloud的挂载配置
```
oem@nextcloud:/srv/compose$ git diff
diff --git a/docker-compose.yml b/docker-compose.yml
index b32cab0..6380ee8 100644
--- a/docker-compose.yml
+++ b/docker-compose.yml
@@ -28,6 +28,7 @@ services:
       - db.env
     volumes:
       - /srv/nextcloud:/var/www/html
+      - /srv/downloads:/downloads
     depends_on:
       - db
```
- 启用`External Storage Support`应用
- 点击设置->外部存储
- 目录名称：Transmission 外部存储：本地 配置：/downloads 可用于：选择用户

## 集成OnlyOffice在线协作编辑
### 重复利用nextcloud.sonnyhcl.top的ssl证书
```
clhu@nextcloud:/srv/onlyoffice/data/certs$ ls
onlyoffice.crt  onlyoffice.key
```
### docker-compose
```
clhu@nextcloud:/srv/compose/onlyoffice$ cat docker-compose.yml 
version: '3'

services:
  web:
    image: onlyoffice/documentserver
    restart: unless-stopped
    container_name: onlyoffice
    volumes:
      - /srv/onlyoffice/data:/var/www/onlyoffice/Data
      - /srv/onlyoffice/logs:/var/log/onlyoffice
      - /srv/onlyoffice/lib:/var/lib/onlyoffice
      - /srv/onlyoffice/db:/var/lib/postgresql
    ports:
      - "8080:80"
      - "8443:443"
```
### 运行onlyoffice
```
clhu@nextcloud:/srv/compose/onlyoffice$ docker-compose up -d
```
### 在nextcloud中配置onlyoffice
  - 在应用中启用OnlyOffice
  - 设置中选择OnlyOffice->填写域名 https://nextcloud.sonnyhcl.top:8443

### 存在的问题
- transmission-daemon用的是debian-transmission这个用户，而nextcloud用的是www-data这个用户，对downloads文件夹只有只读权限
- 视频在线播放没有声音,视频格式的兼容性较差

### 参考链接
- [NextCloud + Transmission 实现 PT下载机以及在线播放](https://www.jianshu.com/p/044de40f7a32)