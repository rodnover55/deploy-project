template "#{node['deploy-project']['path']}/.htaccess" do
  source 'php-cacke.htaccess.erb'
  owner node['apache']['user']
  group node['apache']['group']
end


template "#{node['deploy-project']['path']}/app/Config/core.php" do
  source 'php-cake-core.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/.htaccess" do
  source 'php-cake.htaccess.erb'
  owner node['apache']['user']
  group node['apache']['group']
end