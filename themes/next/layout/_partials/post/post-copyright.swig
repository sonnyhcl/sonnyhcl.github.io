{% set ccLicense = theme.creative_commons.license | lower %}
{% set ccLanguage = theme.creative_commons.language %}
{% set ccIcon = '<i class="fa fa-fw fa-creative-commons"></i>' %}
{% set ccText = ccLicense | upper %}
{% if ccLicense === 'zero' %}
  {% set ccType = 'publicdomain/zero/1.0/' + ccLanguage %}
{% else %}
  {% set ccType = 'licenses/' + ccLicense + '/4.0/' + ccLanguage %}
{% endif %}
{% set ccURL = 'https://creativecommons.org/' + ccType %}

<script src="https://cdn.bootcss.com/jquery/2.0.0/jquery.min.js"></script>
<script src="//cdn.bootcss.com/clipboard.js/1.5.10/clipboard.min.js"></script>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>

<ul class="post-copyright">
  <li class="post-copyright-title">
    <strong>{{ __('post.copyright.title') + __('symbol.colon') }}</strong>
    {{ post.title | default(config.title) }}
  </li>
  <li class="post-copyright-author">
    <strong>{{ __('post.copyright.author') + __('symbol.colon') }}</strong>
    {{ post.author | default(config.author) }}
  </li>
  <li class="post-copyright-created_at">
    <strong>{{ __('post.copyright.created_at') + __('symbol.colon') }}</strong>
    {{ date(post.date, config.date_format) }}
  </li>
  <li class="post-copyright-updated_at">
    <strong>{{ __('post.copyright.updated_at') + __('symbol.colon') }}</strong>
    {{ date(post.updated, config.date_format) }}
  </li>
  <li class="post-copyright-link">
    <strong>{{ __('post.copyright.link') + __('symbol.colon') }}</strong>
    <a href="{{ post.url | default(post.permalink) }}" title="{{ post.title }}">{{ post.url | default(post.permalink) }}</a>
    <a class="copy-path"  title="点击复制文章链接"><i class="fa fa-clipboard" data-clipboard-text="{{ page.permalink }}"  aria-label="复制成功！"></i></a>
  </li>
  <li class="post-copyright-license">
    <strong>{{ __('post.copyright.license_title') + __('symbol.colon') }}</strong>
    {{ __('post.copyright.license_content', next_url(ccURL, ccIcon + ccText)) }}
  </li>
</ul>
<script> 
    var clipboard = new Clipboard('.fa-clipboard');
    $(".fa-clipboard").click(function(){
      clipboard.on('success', function(){
        swal({
          title: "",
          text: '复制文章链接成功',
          icon: "success",
          showConfirmButton: true
          });
	    });
    });  
</script>