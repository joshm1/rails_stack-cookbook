override['nginx']['install_method'] = 'source'
override['nginx']['source']['modules'] = [
  'nginx::http_realip_module',
  'nginx::http_gzip_static_module',
  'nginx::http_ssl_module'
]
override['nginx']['gzip_static'] = 'on'
override['nginx']['realip']['header'] = 'X-Forwarded-For'
override['nginx']['realip']['addresses'] = ['10.0.0.0/8']
