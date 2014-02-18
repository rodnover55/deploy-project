needApacheConfigure = !(node['deploy-project']['disabled'] || []).include?('apache-configure')
needMysqlConfigure = !(node['deploy-project']['disabled'] || []).include?('mysql-configure')

if node['platform_family'] == 'debian'
  include_recipe 'apt'
end

if needApacheConfigure
  include_recipe 'apache2'
  include_recipe 'apache2::mod_rewrite'
end

include_recipe 'database::mysql'

packages = case node["platform"]
             when "debian", "ubuntu"
               %w[mysql-server php5 mysql-client php5-mcrypt php5-curl php5-gd php5-mysql screen git]
             when "redhat", "centos", "fedora"
               %w[mysql-server php mysql php-mcrypt php-curl php-gd php-mysql screen git]

           end

packages.each { |p|
  package p
}

if needApacheConfigure
  execute 'mcrypt' do
    command 'cp /usr/share/php5/mcrypt/mcrypt.ini /etc/php5/mods-available/; php5enmod mcrypt'
    notifies :restart, "service[apache2]", :delayed
  end
end

db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']

if node['deploy-project']['db']['force-config']
  mysql_database db_name do
    connection(
        :host     => node['deploy-project']['db']['host'],
        :username => node['deploy-project']['db']['user'],
        :password => node['deploy-project']['db']['password']
    )
    action :drop
  end
end

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

if needApacheConfigure
  web_app domain do
    server_name domain
    server_aliases aliases
    docroot node['deploy-project']['path']
    allow_override 'All'
  end
end
