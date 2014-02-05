db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']

mysql_database db_name do
  connection(
      :host     => node['deploy-project']['db']['host'],
      :username => node['deploy-project']['db']['user'],
      :password => node['deploy-project']['db']['password']
  )
  not_if { (::File.exists?("#{node['deploy-project']['path']}/config.php") &&
        ::File.exists?("#{node['deploy-project']['path']}/admin/config.php") &&
        ::File.exists?("#{node['deploy-project']['path']}/cli/config.php")) ||
     !::File.exists?(node['deploy-project']['db']['install']) }
  sql { ::File.open(node['deploy-project']['db']['install']).read }
  action :query
end

template "#{node['deploy-project']['path']}/config.php" do
  source 'oc-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/db-config.php" do
  source 'oc-db-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/admin/config.php" do
  source 'oc-admin-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/cli/config.php" do
  source 'oc-cli-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end