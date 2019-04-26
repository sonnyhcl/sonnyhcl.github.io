---
title: install-a-fishlike-zsh
date: 2019-04-27 00:46:50
categories:
- 技术笔记
tags: 
- "zsh"
- "fish"
- "oh-my-zsh"
---

# 伪装成fish的oh-my-zsh安装笔记
都说普通青年用bash，装逼青年用zsh，文艺青年用fish。

<!-- more -->

## 前置环境安装
```
sudo apt-get install zsh curl git
```

## 安装oh-my-zsh
> 参考安装链接 [https://github.com/robbyrussell/oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
> 安装过程中自动切换了默认的shell为zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## 自定义`.zshrc`
- zsh主题选择`fishy`,模仿fish特有的路径简写模式
```
ZSH_THEME="fishy"
```
- 插件清单

```
plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
        z
        cp
        command-not-found
        colored-man-pages
        extract
)
```

- git
    - oh-my-zsh自带且默认开启的插件，提示当前目录所在git仓库的状态的插件
- zsh-syntax-highlighting [参考链接](https://github.com/zsh-users/zsh-syntax-highlighting.git)
    - 模仿fish命令行高亮的插件
    ```
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    ```

- zsh-autosuggestions [参考链接](https://github.com/zsh-users/zsh-autosuggestions)
    - 根据命令历史记录自动推荐和提示的插件
    ```
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ```
- z [参考链接](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins-Overview#fs-jumping)
    - oh-my-zsh自带但是默认不开启的插件，可以无脑跳跃到历史记录中出现过的文件夹
- cp
    - oh-my-zsh自带但是默认不开启的插件，可以在复制的时候显示进度
- command-not-found
    - 自动推荐打错的命令的相关包名
- colored-man-pages
    - 给man page自动高亮，命令行神器
- extract
    - 只需要一个`x`就可以解压任何压缩包，再也不需要手打`tar xfvz`
        
## 配置文件

> [.zshrc](zshrc)