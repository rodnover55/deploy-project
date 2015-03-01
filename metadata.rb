name             'deploy-project'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures deploy-project'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt'
depends 'apache2'
depends 'php'
depends 'database'
depends 'mysql'
depends 'mysql2_chef_gem'
