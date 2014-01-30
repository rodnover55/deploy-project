include_recipe 'apt'
include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
packages = %w[mysql-server php5 mysql-client php5-mcrypt php5-curl php5-gd php5-mysql screen git]
include_recipe 'database::mysql'

packages.each { |p|
  package p
}

db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']
mysql_database db_name do
  connection(
      :host     => node['deploy-project']['db']['host'],
      :username => node['deploy-project']['db']['user'],
      :password => node['deploy-project']['db']['password']
  )
  action :create
end

mysql_database db_name do
  connection(
      :host     => node['deploy-project']['db']['host'],
      :username => node['deploy-project']['db']['user'],
      :password => node['deploy-project']['db']['password']
  )
  only_if do !::File.exists?(node['deploy-project']['db']['config']) &&
      ::File.exists?(node['deploy-project']['db']['install']) end
  sql { ::File.open(node['deploy-project']['db']['install']).read }
  action :query
end

domain = node['deploy-project']['domain'] || "#{node['deploy-project']['project']}.local"
aliases = node['deploy-project']['aliases'] || "www.#{node['deploy-project']['project']}.local"
web_app domain do
  server_name domain
  server_aliases aliases
  docroot node['deploy-project']['path']
end