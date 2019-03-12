---
title: mirror-everything
date: 2019-03-12 19:41:39
tags: Tech
---
本文总结了linux下常见的各式下载站的中国镜像源配置，都是笔者平时拿到一台新电脑或者重装之后（lol）必做的事情之一。

<!-- more -->

## pip mirror
pip国内镜像源有
- 豆瓣：http://pypi.douban.com/simple/
- 清华：https://pypi.tuna.tsinghua.edu.cn/simpl

临时使用只需要在后面加上一行参数
```shell
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
```shell
npm config set registry https://registry.npm.taobao.org
```
## docker mirror
> /etc/docker/daemon.json

这是阿里云为个人开发者提供的docker镜像源，这里就不放出来了。
```json
{
    "registry-mirrors": ["https://xxxxx.mirror.aliyuncs.com"]
}
```
## maven mirror
修改maven根目录下的conf文件夹中的setting.xml文件
> vim apache-maven-3.5.2/conf/settings.xml

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
- 网易Maven镜像源也可以用：https://mirrors.163.com/.help/maven.html