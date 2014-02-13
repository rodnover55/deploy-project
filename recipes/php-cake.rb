template "#{node['deploy-project']['path']}/app/Config/core.php" do
  source 'php-cake-core.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/.htaccess" do
  source 'php-cake-htaccess.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/app/webroot/.htaccess" do
  source 'php-cake-webroot-htaccess.erb'
  owner node['apache']['user']
  group node['apache']['group']
end


file "/etc/php5/conf.d/20-timezone.ini" do
  content "date.timezone = #{node['deploy-project']['php']['timezone']}"
  notifies :restart, "service[apache2]", :delayed
  not_if(node['deploy-project']['php']['timezone'].nil?)
end