---
title: oh-my-fishy-zsh配置
date: 2019-04-27 00:46:50
categories:
- Tech
tags: 
- "zsh"
- "fish"
- "oh-my-zsh"
---

都说普通青年用bash，装逼青年用zsh，文艺青年用fish。

fish是真的好用，但是它最大的问题是与bash不兼容，从而带来各种各样兼容性问题，折腾过fish的人都知道。而zsh有着可定制化的oh-my-zsh框架，同时又是兼容bash语法的，笔者在这里记录一下如何安装一个oh-my-fishy-zsh。

<!-- more -->

## 前置环境安装
### 环境参数
```
clhu@t5 ~> uname -a
Linux t5 4.15.0-48-generic #51~16.04.1-Ubuntu SMP Fri Apr 5 12:01:12 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
clhu@t5 ~> lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.6 LTS
Release:	16.04
Codename:	xenial
clhu@t5 ~> screenfetch                                                     
                          ./+o+-       clhu@t5
                  yyyyy- -yyyyyy+      OS: Ubuntu 16.04 xenial
               ://+//////-yyyyyyo      Kernel: x86_64 Linux 4.15.0-48-generic
           .++ .:/++++++/-.+sss/`      Uptime: 23h 49m
         .:++o:  /++++++++/:--:/-      Packages: 3856
        o:+o+:++.`..```.-/oo+++++/     Shell: zsh 5.1.1
       .:+o:+o/.          `+sssoo+/    Resolution: 3840x1080
  .++/+:+oo+o:`             /sssooo.   DE: Gnome 
 /+++//+:`oo+o               /::--:.   WM: GNOME Shell
 \+/+o+++`o++o               ++////.   WM Theme: Adwaita
  .++.o+++oo+:`             /dddhhh.   GTK Theme: Numix Daily [GTK2/3]
       .+.o+oo:.          `oddhhhh+    Icon Theme: Adwaita
        \+.++o+o``-````.:ohdhhhhh+     Font: Cantarell 11
         `:o+++ `ohhhhhhhhyo++os:      CPU: Intel Core i7-6700HQ CPU @ 3.5GHz
           .o:`.syhhhhhhh/.oo++o`      GPU: GeForce GTX 960M
               /osyyyyyyo++ooo+++/     RAM: 7488MiB / 15930MiB
                   ````` +oo+++o\:    
                          `oo++.      
```

### 安装zsh
```
sudo apt-get install zsh curl git
```

## 安装[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
> 安装过程中会自动切换默认的shell为zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## 自定义你的[.zshrc](zshrc)
> 安装完oh-my-zsh的下一步就是自定义配置文件，下面罗列了一些模仿fish必备的插件

### fishy主题
- zsh主题选择`fishy`，可以模仿fish特有的路径简写模式。

```
ZSH_THEME="fishy"
```

### 插件清单
```
plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-completions
        z
        history-substring-search
        command-not-found
        colored-man-pages
        extract
)
```

- git: 提示当前目录所在git仓库的状态的插件
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting.git): 模仿fish命令行高亮的插件
    
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): 根据命令历史记录自动推荐和提示的插件

```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

- [zsh-completions](https://github.com/zsh-users/zsh-completions): 自动命令补全，类似bash-completions功能的插件

```
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
```
- [history-substring-search](https://github.com/zsh-users/zsh-history-substring-search): 按住向上箭头可以搜索出现过该关键字的历史命令
```
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

- [z](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/z): 可以无脑跳跃到历史记录中出现过的文件夹
- [command-not-found](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/command-not-found)：会自动根据出错的命令，推荐该命令可能相关的包
- [colored-man-pages](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/colored-man-pages)： 给man page自动高亮，命令行神器
- [extract](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/extract)： 只需要一个`x`就可以解压任何压缩包，再也不需要手打`tar xfvz`

## 最终效果
配置完成之后的效果如下图所示

![zsh](zsh.png)
