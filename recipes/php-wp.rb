db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']

# unless default['deploy-project']['php-wp']['origin_host'].nil? ||
#     default['deploy-project']['php-wp']['new_host'].nil?
#   origins = (default['deploy-project']['php-wp']['origin_host'].is_a(Array)) ? (default['deploy-project']['php-wp']['origin_host']) : ([default['deploy-project']['php-wp']['origin_host']])
#
#   install_file = "/tmp/import.convert.sql"
#
#   origins.each do |host|
#     execute "cat #{node['deploy-project']['db']['install']} | sed 's##{host}##{default['deploy-project']['php-wp']['new_host']}#g' > /tmp/import.convert.sql" do
#       only_if { (node['deploy-project']['db']['install_type'] != 'none') || ::File.exists?(node['deploy-project']['db']['install']) }
#     end
#   end
# else
#   install_file = "/tmp/import.convert.sql"
# end

mysql_database db_name do
  connection(
      :host     => node['deploy-project']['db']['host'],
      :username => node['deploy-project']['db']['user'],
      :password => node['deploy-project']['db']['password']
  )
  not_if { (::File.exists?("#{node['deploy-project']['path']}/wp-config.php") &&
      (node['deploy-project']['db']['install_type'] != 'force')) ||
      !::File.exists?(node['deploy-project']['db']['install']) ||
      (node['deploy-project']['db']['install_type'] == 'none') }
  sql { ::File.open(node['deploy-project']['db']['install']).read }
  action :query
end

template "#{node['deploy-project']['path']}/wp-config.php" do
  source 'wp-wp-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end
