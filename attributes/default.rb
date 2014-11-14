default['deploy-project']['db']['host'] = '127.0.0.1'
default['deploy-project']['db']['user'] = 'root'
default['deploy-project']['db']['password'] = ''
default['deploy-project']['db']['install_type'] = 'normal'
default['deploy-project']['db']['provider'] = 'pdo'
default['deploy-project']['db']['database'] = default['deploy-project']['project']

default['deploy-project']['base'] = '/'
default['deploy-project']['redirect'] = nil
default['deploy-project']['aliases'] = []

default['php']['modules_conf_dir'] = '/etc/php5/mods-available/'
default['deploy-project']['repo']['erase_path'] = false
default['deploy-project']['repo']['method'] = 'sync'
default['deploy-project']['repo']['private_key'] = '/root/.ssh/id_rsa'
default['deploy-project']['repo']['public_key'] = '/root/.ssh/id_rsa.pub'

default['deploy-project']['php']['timezone'] = nil
default['deploy-project']['dev'] = false

default['yum']['epel']['exclude'] = 'test*'

default['deploy-project']['ssh']['keydir'] = '/tmp/deploy'