include_recipe 'deploy-project::enviroment'
package 'php5-xdebug'

ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
remote_ip = ip.gsub /\.\d+$/, '.1'

template "#{node['php']['modules_conf_dir']}xdebug.ini" do
  source 'php-xdebug.ini.erb'
  owner node['apache']['user']
  group node['apache']['group']
  variables({remote_host: remote_ip})
  notifies :reload, "service[apache2]", :delayed
end
include_recipe 'deploy-project::configure'
