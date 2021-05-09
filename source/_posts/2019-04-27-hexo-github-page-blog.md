---
title: Hexo+GitHub搭建个人博客
date: 2019-04-27 15:33:17
updated: 2019-04-27 15:33:17
categories:
- Tech
tags:
- "Hexo"
- "Github Page"
- "Next"
- "Mist"
---
本着随便写点什么的想法，我开始搭建了这个博客站点。想着是越简单越好，越朴素越好，现成的GitHub Pages不用白不用，最好是能直接基于markdown就能生成页面，最终选择了GitHub Pages+Hexo+Next Mist+Travis CI的方案。

<!-- more -->

## 技术方案
### GitHub Pages
GitHub提供了一个Pages的服务，给广大薅羊毛用户:)创造了一个免费搭建静态网页博客的机会。只要你有github账号，就可以有一个对应的`<username>.github.io`专属域名，。默认情况下我们需要创建一个`<username>.github.io`的github项目，这个项目中的网页内容将会被自动呈现在`https://<username>.github.io`下。假设该项目中有一个`index.html`文件，内容是`Hello World`，打开对应的网址就会看到大大的`Hello World`字样。

### Hexo
虽然GitHub提供了一个非常完美的静态文件托管服务，但是我们不能每次手写一通复杂的html，写点东西的小激情会很容易被耗损。也不能就是一个纯文本页面，那也太朴素了一点。这时候就需要类似[Hexo](https://hexo.io/zh-cn/)这样的快速、简洁且高效的博客框架，可以很方便地将markdown渲染为一定样式的页面。

选中Hexo的主要原因是因为它有一套完整的markdown支持体系，除了一开始的配置之外，以后每次写文章只需要新建一个md文件就可以开写了，在书写过程中不需要再额外考虑样式等问题。

一个完整的Hexo项目都会包括以下几个部分，根目录下的`_config.yml`被称作为站点配置文件，`scaffolds`内存储的是页面的markdown模板，`themes`下存放主题插件（下一节里介绍），里面也会包含一个`_config.yml`被称之为主题配置文件，至于`source`里放的就是你写的markdown博文啦。

{% spoiler "站点配置文件 _config.yml" %}
{% codeblock site_config lang:yml %}
# Hexo Configuration
## Docs: https://hexo.io/docs/configuration.html
## Source: https://github.com/hexojs/hexo/

# 站点基本信息配置
title: 胡一刀的随笔
subtitle: May the force be with you
description: 分享技术
keywords: 博客
author: sonnyhcl
language: zh-CN
timezone: Asia/Shanghai 

# 站点域名配置
## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
url: https://sonnyhcl.com/
root: /
## 很多博客都会选择在前面加上:year/:month/:day/:title/作为链接，个人喜好问题
permalink: :title/

# 文件夹配置
source_dir: source
public_dir: public
tag_dir: tags
archive_dir: archives
category_dir: categories
code_dir: downloads/code
i18n_dir: :lang
skip_render:

# 博文配置
new_post_name: :year-:month-:day-:title.md # File name of new posts
default_layout: post
titlecase: false # Transform title into titlecase
external_link: true # Open external links in new tab
filename_case: 0
render_drafts: false
post_asset_folder: true
relative_link: false
future: true
highlight:
  enable: true
  line_number: true
  auto_detect: true
  tab_replace: true
  
# 主页配置
# path: Root path for your blogs index page. (default = '')
# per_page: Posts displayed per page. (0 = disable pagination)
# order_by: Posts order. (Order by date descending by default)
index_generator:
  path: ''
  per_page: 10
  order_by: -date
  
# 分类与标签
default_category: Tech
category_map:
tag_map:

# 日期时间格式
## Hexo uses Moment.js to parse and display date
## You can customize the date format as defined in
## http://momentjs.com/docs/#/displaying/format/
date_format: YYYY-MM-DD
time_format: HH:mm:ss

# 分页设置
## Set per_page to 0 to disable pagination
per_page: 10
pagination_dir: page

# 扩展插件
## Plugins: https://hexo.io/plugins/
Plugins: hexo-generate-feed

# 插件：阅读时间估计
symbols_count_time:
  symbols: true
  time: true
  total_symbols: true
  total_time: true

# 主题选择
## Themes: https://hexo.io/themes/
theme: next
{% endcodeblock %}
{% endspoiler %}


### Next Mist
Hexo负责的是文件转换，而静态网页的样式在主题插件中定义。Next就是这样一个主题插件，目前NexT支持如下三种Scheme，本着简洁、朴素的原则，我最后挑选了[`Next Mist`](https://theme-next.iissnan.com/getting-started.html#select-scheme)作为博客的主题。
- Muse - 默认 Scheme，这是NexT最初的版本，黑白主调，大量留白
- Mist - Muse的紧凑版本，整洁有序的单栏外观
- Pisces - 双栏Scheme，小家碧玉似的清新

![theme](theme.png)

{% spoiler "主题配置文件 _config.yml" %}
{% codeblock theme_config lang:yml %}
这个配置文件实在是太长了，我就不复制过来污染眼睛了
[themes_next_config.yml](https://github.com/sonnyhcl/sonnyhcl.github.io/blob/source/themes/next/_config.yml)
{% endcodeblock %}
{% endspoiler %}

### Travis CI
由Markdown文件自动生成静态文件并部署到GitHub Pages这个流程可以说是非常机械和重复的。虽然hexo也有一个deploy的功能，但是总归还是要手工操作一波。源文件放在source分支，生成的静态文件部署在master分支上，本着能自动绝不手动的原则，这里我们利用[Travis CI](https://travis-ci.org/)来自动完成部署的步骤。


我们需要在travis上设置在配置文件中用到的四个环境变量，其中`$GITHUB_TOKEN`需要在GitHub申请一个[Personal Token](https://github.com/settings/tokens)，`$CUSTOM_DOMAIN`是博客所在的域名（即`<username>.github.io`)，`$GIT_NAME`和`$GIT_EMAIL`则是你的github账户。当我们创建或者修改了博文并推送到source分支之后，travis会自动拉取并生成最新的静态内容并推送到master分支。

![travis](travis.png)

{% spoiler .travis.yml %}
{% codeblock lang:yml %}
language: node_js
node_js: stable

cache:
  apt: true
  yarn: true
  directories:
    - node_modules

before_install:
  - yarn global add hexo-cli

install:
  - yarn install

script:
  - hexo clean
  - hexo generate

# 仅当source分支更新的时候触发
branches:
  only:
    - source

# 部署到GitHub Pages 
deploy:
  provider: pages
  skip_cleanup: true
  # 不保留历史，避免git repo体积过度膨胀
  keep-history: false
  github_token: $GITHUB_TOKEN
  fqdn: $CUSTOM_DOMAIN
  name: $GIT_NAME
  email: $GIT_EMAIL
  verbose: true
  # hexo生成的静态文件在public文件夹中
  local_dir: public
  # 部署到master分支
  target-branch: master
  on:
    branch: source
{% endcodeblock %}
{% endspoiler %}

## 常规操作
### 开发环境部署
如果要在一台新电脑上写博文，那么要先配置一下开发环境，其实这一步完全可以参考前面的.travis.yml中的步骤来，本质上是相同的。

- 首先确保你已经安装了[node](https://github.com/nvm-sh/nvm)和[yarn](https://yarnpkg.com/zh-Hans/docs/install#debian-stable)。

- 安装hexo

```
yarn global add hexo-cli
```

- 安装package.json中依赖

```
yarn install
```

- 到这里就部署好你的本地开发环境了

### 一篇博文的诞生
- 首先需要想好要写什么，想一个简短的题目

```
hexo new create-a-new-post
```
- 然后就会在source/_posts文件夹下生成一个`日期+标题`的文件夹和markdown文件，可以直接在markdown中引用同名文件夹下的图片素材，如下所示。

```
![travis](travis.png)
```
## 参考链接
- [HEXO+Github搭建博客](http://blog.codesfile.com/2017/12/16/HEXO+Github搭建博客)
- [HEXO搭配Next主题修改博客](http://blog.codesfile.com/2017/12/16/HEXO%E6%90%AD%E9%85%8DNext%E4%B8%BB%E9%A2%98%E4%BF%AE%E6%94%B9%E5%8D%9A%E5%AE%A2/)
- [Next主题美化](https://almostover.ru/2016-01/hexo-theme-next-test/)

> 样式一次搞定不存在的，每次看到别人博客里好玩的都会研究下怎么neng过来lol

{% note danger %}
求助！！要怎么样才能实现下面这样的效果呢？spoiler+codeblock+include三级嵌套！！
{% endnote %}

```
{% spoiler "站点配置文件 _config.yml" %}

{% codeblock site_config.yml lang:yml %}
{% include _config.yml %}
{% endcodeblock %}

{% endspoiler %}
```