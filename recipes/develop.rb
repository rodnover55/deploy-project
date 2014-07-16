include_recipe 'deploy-project::enviroment'


web_user = Etc.getpwnam(node['apache']['user'])
mount node['deploy-project']['path'] do
  fstype 'vboxsf'
  options "uid=#{web_user.uid},gid=#{web_user.gid}"
  device node['deploy-project']['path']
  action :umount
end

mount node['deploy-project']['path'] do
  fstype 'vboxsf'
  options "uid=#{web_user.uid},gid=#{web_user.gid}"
  device node['deploy-project']['path']
  action :mount
end

package 'php5-xdebug'

ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
remote_ip = ip.gsub /\.\d+$/, '.1'

needApacheConfigure = !(node['deploy-project']['disabled'] || []).include?('apache-configure')
needMysqlConfigure = !(node['deploy-project']['disabled'] || []).include?('mysql-configure')

if needApacheConfigure
  template "#{node['php']['modules_conf_dir']}xdebug.ini" do
    source 'php-xdebug.ini.erb'
    variables({remote_host: remote_ip})
    notifies :reload, "service[apache2]", :delayed
  end
end

if needMysqlConfigure
  service 'mysql' do
    action :nothing
  end

  template "/etc/mysql/conf.d/custom.cnf" do
    source 'mysql-custom-dev.cnf.erb'
    notifies :restart, "service[mysql]", :delayed
  end

  mysql_database_user "#{node['deploy-project']['db']['user']}" do
    connection(
        :host     => node['deploy-project']['db']['host'],
        :username => node['deploy-project']['db']['user'],
        :password => node['deploy-project']['db']['password']
    )
    password node['deploy-project']['db']['password']
    host '%'
    action :grant
  end
end

template '/usr/bin/fakemail.sh' do
  source 'fakemail.sh.erb'
  mode 0755
end

case node["platform"]
  when "debian", "ubuntu"
    php_fakemail_config_path = '/etc/php5/apache2/conf.d/50-fakemail.ini'
    service = 'service[apache2]'
  when 'redhat', 'centos', 'fedora'
    php_fakemail_config_path = '/etc/php.d/fakemail.ini'
    service = 'service[httpd]'
end

directory File.dirname(php_fakemail_config_path)

template php_fakemail_config_path do
  source 'php-fakemail.ini.erb'
  notifies :restart, service, :delayed
end

node.override['deploy-project']['dev'] = true

include_recipe 'deploy-project::configure'
