name             'rails_stack'
maintainer       'Josh McDade'
maintainer_email 'josh.ncsu@gmail.com'
license          'All rights reserved'
description      'Installs/Configures rails_stack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.14'

depends 'apt'
depends 'nginx'
depends 'logrotate'
depends 'monit'
