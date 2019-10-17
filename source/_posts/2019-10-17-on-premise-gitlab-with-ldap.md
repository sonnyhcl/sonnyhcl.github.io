---
title: 搭建本地私有云之集成LDAP的GitLab
categories:
  - Tech
tags:
  - on-premise-cloud
  - GitLab
  - FreeIPA
  - LDAP
date: 2019-10-17 13:09:01
---

这个系列是笔者在为实验室搭建本地私有云的过程中所记载的笔记,看起来会比较杂乱 :)

本文介绍在本地搭建自己的gitlab服务,并集成FreeIPA提供的LDAP认证

<!-- more -->
首先我们需要一台崭新的ubuntu18.04的虚拟机,虚拟机的初始化配置此处不再赘述.我们为该虚拟机新增一块500GB的数据盘用作数据存储.

## 搭建gitlab服务

### 挂载数据盘
```
sudo mkfs.ext4 /dev/vdb
echo "/dev/vdb	/srv	ext4	defaults 	0	0" | sudo tee -a /etc/fstab
sudo mount /dev/vdb /srv
sudo chown -R oem:oem /srv # oem可以替换成你的用户名
lsblk
```

### 安装docker和docker-compose
```
sudo apt install docker.io docker-compose
sudo usermod -aG docker oem
sudo systemctl enable docker
```

### 添加LDAP认证用户
在FreeIPA中添加GitLab用户,在gitlab.rb中配置为LDAP认证用户使用
```
login: gitlab
FirstName: GitLab
LastName: Bind User
Password: gitlab
```

### 配置gitlab.rb
```
clhu@gitlab-old:/srv/gitlab/config$ sudo cat gitlab.rb | egrep -v "^#|^$"
external_url "https://gitlab.sonnyhcl.top"
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.sonnyhcl.top.pem"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.sonnyhcl.top.key"
gitlab_rails['time_zone'] = 'Asia/Shanghai'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_user_name'] = "xxx@163.com"
gitlab_rails['smtp_password'] = "xxx"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = :login
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['gitlab_email_reply_to'] = 'noreply@163.com'
gitlab_rails['gitlab_email_from'] = "xxx@163.com"
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
main:
  label: 'LDAP'
  host: 'ipa.sonnyhcl.top'
  port: 389
  uid: 'uid'
  method: 'tls'
  bind_dn: 'uid=gitlab,cn=users,cn=accounts,dc=sonnyhcl,dc=top'
  password: 'gitlab'
  encryption: 'plain'
  base: 'cn=accounts,dc=sonnyhcl,dc=top'
  verify_certificates: false
  attributes:
    username: ['uid']
    email: ['mail']
    name: 'displayName'
    first_name: 'givenName'
    last_name: 'sn'
    sync_ssh_keys: true
EOS
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_keep_time'] = 604800
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'cn-north-1',
  'aws_access_key_id' => 'xxxxxxxx',
  'aws_secret_access_key' => 'xxxxxxxx'
}
gitlab_rails['backup_upload_remote_directory'] = 'gitlab-sonnyhcl-top'
postgresql['shared_buffers'] = "2048MB"
nginx['real_ip_header'] = 'X-Forwarded-For'
nginx['custom_error_pages'] = {
  '404' => {
    'title' => '404 Page',
    'header' => 'GitLab',
    'message' => 'https://gitlab.sonnyhcl.top'
  }
}
```

### 配置docker-compose.yml
```
oem@gitlab:~/compose$ cat docker-compose.yml 
version: '3'

services:
  gitlab:
   image: 'gitlab/gitlab-ce:latest'
   restart: unless-stopped
   container_name: gitlab
   hostname: 'gitlab.sonnyhcl.top'
   ports:
     - '80:80'
     - '443:443'
     - '22:22'
   volumes:
     - '/srv/gitlab/config:/etc/gitlab'
     - '/srv/gitlab/logs:/var/log/gitlab'
     - '/srv/gitlab/data:/var/opt/gitlab'
```
### 启动gitlab服务
```
docker-compose up -d
```


## 备份
### 备份到AWS
    - 创建AWS S3存储桶 gitlab-sonnyhcl-top
    - 创建AWS IAM身份 gitlab.sonnyhcl.top
    - [x] 编程访问:为 AWS API、CLI、SDK 和其他开发工具启用 访问密钥 ID 和 私有访问密钥 。 
    - [x] 赋予AWS S3 Full Access

### 备份数据
```
docker exec -t gitlab gitlab-rake gitlab:backup:create >> /home/clhu/gitlab-backup.log
```

### 备份配置
```
docker exec -t gitlab /bin/sh -c "umask 0077; tar cfz /var/opt/gitlab/backups/config/$(date "+%s-etc-gitlab.tgz") -C / etc/gitlab"
```

### 定时备份
```
clhu@gitlab:/srv/gitlab$ crontab -l
# m h  dom mon dow   command
10 5 * * * docker exec -t gitlab gitlab-rake gitlab:backup:create >> /home/clhu/gitlab-backup.log
0 5 * * * docker exec -t gitlab /bin/sh -c "umask 0077; tar cfz /var/opt/gitlab/backups/config/$(date "+%s-etc-gitlab.tgz") -C / etc/gitlab"
```

### 重启gitlab
```
# 修改gitlab.rb之后必须重配置一下
docker exec -t gitlab gitlab-ctl reconfigure
```

## 参考链接
- [https://docs.gitlab.com/omnibus/docker/#install-gitlab-using-docker-compose](https://docs.gitlab.com/omnibus/docker/#install-gitlab-using-docker-compose)
