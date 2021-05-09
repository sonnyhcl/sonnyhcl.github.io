---
title: 常用国内加速镜像源配置
date: 2019-03-12 19:41:39
updated: 2019-03-12 19:41:39
categories:
- Tech
tags: 
- "镜像源"
- "mirrors"
- "pip"
- "docker"
- "maven"
- "npm"
---
本文总结了linux下常见的各式下载站的国内加速镜像源配置，都是笔者平时拿到一台新电脑或者重装之后（lol）必做的事情之一。

<!-- more -->

## pip mirror
常用的pip国内镜像源有
- 豆瓣：http://pypi.douban.com/simple/
- 清华：https://pypi.tuna.tsinghua.edu.cn/simple

临时使用只需要在后面加上一行参数
```
pip install flask -i https://pypi.tuna.tsinghua.edu.cn/simple   
```
如果想要一劳永逸的话
> vim ~/.pip/pip.conf

```
[global]  
index-url = https://pypi.tuna.tsinghua.edu.cn/simple  
[install]  
trusted-host=pypi.tuna.tsinghua.edu.cn
disable-pip-version-check = true  
timeout = 6000    
```

## npm mirror
```
npm config set registry https://registry.npm.taobao.org
```

## docker mirror
> `/etc/docker/daemon.json`

```json
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://quay.mirrors.ustc.edu.cn",
        "https://gcr.mirrors.ustc.edu.cn"
    ]
}
```

## maven mirror
修改maven根目录下的conf文件夹中的setting.xml文件
> `/home/whoami/.m2/settings.xml`

```xml
<mirrors>
    <mirror>
        <id>nexus-aliyun</id>
        <mirrorOf>central</mirrorOf>
        <name>Nexus aliyun</name>
        <url>http://maven.aliyun.com/nexus/content/repositories/central</url>
    </mirror>
</mirrors>
```
- 详细的设置参考也可以看[网易maven的镜像设置教程](https://mirrors.163.com/.help/maven.html)