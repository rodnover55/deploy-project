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

domain = node['deploy-project']['domain'] || "#{node['deploy-project']['project']}.local"
aliases = node['deploy-project']['aliases'] || ["www.#{node['deploy-project']['project']}.local"]

web_app domain do
  server_name domain
  server_aliases aliases
  docroot node['deploy-project']['path']
end

#execute "Change permissions for #{node['deploy-project']['path']}" do
#  command "umount #{node['deploy-project']['path']} && mount -t vboxsf -o uid=`id -u #{node['apache']['user']}`,gid=`id -g #{node['apache']['group']}` #{node['deploy-project']['path']} #{node['deploy-project']['path']}"
#end
