needApacheConfigure = !(node['deploy-project']['disabled'] || []).include?('apache-configure')
needMysqlConfigure = !(node['deploy-project']['disabled'] || []).include?('mysql-configure')

if node['platform_family'] == 'debian'
  include_recipe 'apt'
end

case node["platform"]
  when "centos"
    include_recipe 'yum-epel'
end

packages = case node["platform"]
             when "debian", "ubuntu"
               %w[mysql-server php5 mysql-client php5-json php5-mcrypt php5-curl php5-gd php5-mysql screen git wget ruby-dev]
             when "redhat", "centos", "fedora"
               %w[mysql-server php mysql php-mcrypt php-curl php-mbstring php-gd php-mysql screen git php-domxml php-soap wget]

           end

packages.each do |p|
  package p
end

if needApacheConfigure
  include_recipe 'apache2'
  include_recipe 'apache2::mod_rewrite'
end

if needApacheConfigure
  ['/etc/php5/apache2/conf.d/20-timezone.ini',
   '/etc/php5/cli/conf.d/20-timezone.ini'].each do |fn|
    directory ::File.dirname(fn) do
      recursive true
    end
    file fn do
      content "date.timezone = #{node['deploy-project']['timezone']}"
      notifies :restart, 'service[apache2]', :delayed
      not_if { node['deploy-project']['timezone'].nil? }
    end
  end
end

service_mysql = case node["platform"]
  when "debian", "ubuntu"
    'mysql'
  when "redhat", "centos", "fedora"
    'mysqld'
end
service service_mysql do
  action [:enable, :start]
end

case node["platform"]
  when "centos"
    service 'httpd' do
      action [:enable, :restart]
    end
end

if needApacheConfigure
  if %w[saucy trusty].include?(node['lsb']['codename'])
    execute 'mcrypt' do
      command 'mv /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/; php5enmod mcrypt'
      only_if { ::File.exist?('/etc/php5/conf.d/mcrypt.ini')}
      notifies :restart, "service[apache2]", :delayed
    end
    execute 'mcrypt' do
      command 'php5enmod mcrypt'
      notifies :restart, "service[apache2]", :delayed
    end
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

if needMysqlConfigure
  directory '/etc/mysql/'
  if %w(redhat centos fedora).include?(node["platform"])
    file '/etc/mysql/my.cnf' do
      content '!includedir /etc/mysql/conf.d/'
    end
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

unless node['deploy-project']['hostname'].nil?
  case node["platform"]
    when "debian", "ubuntu"
      file'/etc/hostname' do
        content node['deploy-project']['hostname']
      end
    when "redhat", "centos", "fedora"
      execute "sed -ie 's/HOSTNAME=.*/HOSTNAME=#{node['deploy-project']['hostname']}/g' /etc/sysconfig/network"
  end
  execute "hostname #{node['deploy-project']['hostname']}"
end

include_recipe 'deploy-project::backup'