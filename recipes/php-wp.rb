db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']

mysql_database db_name do
  connection(
      :host     => node['deploy-project']['db']['host'],
      :username => node['deploy-project']['db']['user'],
      :password => node['deploy-project']['db']['password']
  )
  not_if { ::File.exists?("#{node['deploy-project']['path']}/wp-config.php") ||
      !::File.exists?(node['deploy-project']['db']['install']) }
  sql { ::File.open(node['deploy-project']['db']['install']).read }
  action :query
end

template "#{node['deploy-project']['path']}/wp-config.php" do
  source 'wp-wp-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end
