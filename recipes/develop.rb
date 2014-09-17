include_recipe 'deploy-project::enviroment'



execute "umount #{node['deploy-project']['path']}" do
  returns [0, 1]
end
execute "mount -t vboxsf -o rw,uid=`id -u #{node['apache']['user']}`,gid=`id -g #{node['apache']['user']}` #{node['deploy-project']['path']} #{node['deploy-project']['path']}" do
  returns [0, 1]
end

case node["platform"]
  when 'redhat', 'centos', 'fedora'
    package 'php-pecl-xdebug'
  when "debian", "ubuntu"
    package 'php5-xdebug'
end

ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
remote_ip = ip.gsub /\.\d+$/, '.1'

needApacheConfigure = !(node['deploy-project']['disabled'] || []).include?('apache-configure')
needMysqlConfigure = !(node['deploy-project']['disabled'] || []).include?('mysql-configure')

if needApacheConfigure
  dirConfig = case node["platform"]
    when 'redhat', 'centos', 'fedora'
      '/etc/php.d/'
    when "debian", "ubuntu"
      node['php']['modules_conf_dir']
  end
  template "#{dirConfig}xdebug.ini" do
    source 'php-xdebug.ini.erb'
    variables({remote_host: remote_ip})
    notifies :reload, "service[apache2]", :delayed
  end
end

if needMysqlConfigure
  mysqlServ = case node["platform"]
                when 'redhat', 'centos', 'fedora'
                  'mysqld'
                when "debian", "ubuntu"
                  'mysql'
              end
  service mysqlServ do
    supports :status => true, :restart => true
    action :nothing
  end

  directory '/etc/mysql/conf.d' do
    recursive true
  end
  template "/etc/mysql/conf.d/custom.cnf" do
    source 'mysql-custom-dev.cnf.erb'
    notifies :restart, "service[#{mysqlServ}]", :immediate
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
    php_fakemail_config_paths = ['/etc/php5/apache2/conf.d/50-fakemail.ini',
                                '/etc/php5/cli/conf.d/50-fakemail.ini']
    service = 'service[apache2]'
  when 'redhat', 'centos', 'fedora'
    php_fakemail_config_paths = ['/etc/php.d/fakemail.ini']
    service = 'service[httpd]'
end
php_fakemail_config_paths.each do |p|
  directory File.dirname(p)
  template p do
    source 'php-fakemail.ini.erb'
    notifies :restart, service, :delayed
  end
end



directory "/var/mail/sendmail/" do
  mode 0777
end

%w(cur new tmp).each do |d|
  directory "/var/mail/sendmail/#{d}" do
    mode 0777
  end
end

node.override['deploy-project']['dev'] = true

include_recipe 'deploy-project::configure'
