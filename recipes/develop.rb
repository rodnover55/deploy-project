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
    source 'mysql-custom.cnf.erb'
    notifies :restart, "service[mysql]", :delayed
  end

  mysql_database_user 'root' do
    connection(
        :host     => node['deploy-project']['db']['host'],
        :username => node['deploy-project']['db']['user'],
        :password => node['deploy-project']['db']['password']
    )
    action     :grant
  end
end

include_recipe 'deploy-project::configure'
