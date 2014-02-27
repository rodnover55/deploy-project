db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']

mysql_database db_name do
  connection(
      :host     => node['deploy-project']['db']['host'],
      :username => node['deploy-project']['db']['user'],
      :password => node['deploy-project']['db']['password']
  )
  not_if { (::File.exists?("#{node['deploy-project']['path']}/config.php") &&
        ::File.exists?("#{node['deploy-project']['path']}/admin/config.php") &&
        ::File.exists?("#{node['deploy-project']['path']}/cli/config.php") &&
        (node['deploy-project']['db']['install_type'] != 'force')) ||
     !::File.exists?(node['deploy-project']['db']['install']) ||
      node['deploy-project']['db']['install_type'] == 'none'}
  sql { ::File.open(node['deploy-project']['db']['install']).read }
  action :query
end

template "#{node['deploy-project']['path']}/config.php" do
  source 'oc-config.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/db_config.php" do
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

directory "#{node['deploy-project']['path']}/system/cache/" do
  owner node['apache']['user']
  group node['apache']['group']
  action :create
end

directory "#{node['deploy-project']['path']}/image/cache/" do
  owner node['apache']['user']
  group node['apache']['group']
  action :create
end

template "#{node['deploy-project']['path']}/.htaccess" do
  if node['deploy-project']['php-oc']['htaccess'].nil?
    source 'oc-htaccess.erb'
  else
    source node['deploy-project']['php-oc']['htaccess']['template']
    cookbook node['deploy-project']['php-oc']['htaccess']['cookbook']
  end


  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/deploy/migrations-db.php" do
  source 'doc-migrations-db.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

unless node['deploy-project']['db']['migrate'].nil?
  execute "migrate" do
    command "sleep 5; #{node['deploy-project']['db']['migrate']}"
    cwd node['deploy-project']['db']['migrate_cwd']
  end
end

unless node['deploy-project']['php-oc']['informations'].nil?
  node['deploy-project']['php-oc']['informations'].each do |information|
    php_oc_information information['template'] do
      keyword information['keyword']
      title information['title']
      sort_order information['sort_order'] || 0
      bottom information['bottom'] || 1
      status information['status'] || 1
      force information['force'] || false
    end
  end
end

unless node['deploy-project']['php-oc']['settings'].nil?
  node['deploy-project']['php-oc']['settings'].each do |group, settings|
    settings.each do |key, value|
      php_oc_setting key do
        group group
        value value
      end
    end
  end
end

unless node['deploy-project']['php-oc']['modules'].nil?
  node['deploy-project']['php-oc']['modules'].each do |name, action|
    php_oc_extention name do
      action action
      type 'module'
    end
  end
end

unless node['deploy-project']['php-oc']['payments'].nil?
  node['deploy-project']['php-oc']['payments'].each do |name, action|
    php_oc_extention name do
      action action
      type 'payment'
    end
  end
end

unless node['deploy-project']['php-oc']['permissions'].nil?
  node['deploy-project']['php-oc']['permissions'].each do |type, permissions|
    permissions.each do |page, permission|
      if permission.is_a?(Array)
        permission.each do |name|
          php_oc_permission name do
            type type
            page page
          end
        end
      else
        permission.each do |action, groups|
          groups.each do |name|
            php_oc_permission name do
              type type
              page page
              action action
            end
          end
        end
      end
    end
  end
end

if node['deploy-project']['dev']
  execute "php cli/index.php configure/password 'admin' '123123'" do
    command "php cli/index.php configure/password 'admin' '123123'"
    cwd node['deploy-project']['path']
    action :run
  end
end