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

{% spoiler ".zshrc" %}
{% codeblock lang:yml %}
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH="/home/clhu/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="fishy"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
bindkey ',' autosuggest-accept

alias re="source ~/.zshrc"
{% endcodeblock %}
{% endspoiler %}
> 安装完oh-my-zsh的下一步就是自定义配置文件，下面罗列了一些模仿fish必备的插件

### fishy主题
zsh主题选择`fishy`，可以模仿fish特有的路径简写模式。

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
- [z](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/z): 可以无脑跳跃到历史记录中出现过的文件夹中
- [command-not-found](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/command-not-found)：会自动根据出错的命令，推荐该命令可能相关的包
- [colored-man-pages](https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/colored-man-pages)： 给man page自动高亮，命令行神器
- [extract](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/extract)： 只需要一个`x`就可以解压任何压缩包，再也不需要手打`tar xfvz`
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

## 最终效果
配置完成之后的效果如下图所示

![zsh](zsh.png)
