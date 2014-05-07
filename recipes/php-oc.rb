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
      (node['deploy-project']['db']['install_type'] == 'none') }
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

%w(modules payments feeds).each do |extention|
  unless node['deploy-project']['php-oc'][extention].nil?
    node['deploy-project']['php-oc'][extention].each do |name, action|
      php_oc_extention name do
        action action
        type extention
      end
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

unless node['deploy-project']['php-oc']['geo_zones'].nil?
  node['deploy-project']['php-oc']['geo_zones'].each do |geo_zone|
    php_oc_geo_zone geo_zone['slug'] do
      geo_zone_name geo_zone['name']
      description geo_zone['description']
      zones geo_zone['zones']
    end
  end
end

unless node['deploy-project']['php-oc']['tax_rates'].nil?
  node['deploy-project']['php-oc']['tax_rates'].each do |tax_rate|
    php_oc_tax_rate tax_rate['slug'] do
      tax_rate_name tax_rate['name']
      rate tax_rate['rate']
      type tax_rate['type']
      geo_zone tax_rate['geo_zone']
    end
  end
end

unless node['deploy-project']['php-oc']['tax_classes'].nil?
  node['deploy-project']['php-oc']['tax_classes'].each do |tax_class|
    php_oc_tax_class tax_class['slug'] do
      title tax_class['title']
      description tax_class['description']
      tax_rule tax_class['tax_rule']
    end
  end
end

unless node['deploy-project']['php-oc']['languages'].nil?
  node['deploy-project']['php-oc']['languages'].each do |language|
    php_oc_language language['name'] do
      code language['code']
      locale language['locale']
      image language['image']
      directory language['directory']
      filename language['filename']
    end
  end
end

unless node['deploy-project']['php-oc']['enabled_languages'].nil?
  languages = node['deploy-project']['php-oc']['enabled_languages'].join(' ')
  execute "php cli/index.php configure/enable_languages #{languages}" do
    cwd node['deploy-project']['path']
    action :run
  end
end

unless node['deploy-project']['php-oc']['customers_groups'].nil?
  node['deploy-project']['php-oc']['customers_groups'].each do |customer_group|
    php_oc_customer_group customer_group['slug'] do
      approval customer_group['approval']
      sort_order customer_group['sort_order']
      discount customer_group['discount']
      discount_minimum customer_group['discount_minimum']
      description customer_group['description']

      unless customer_group['customer_group_id'].nil?
        customer_group_id customer_group['customer_group_id']
      end
    end
  end
end

unless node['deploy-project']['php-oc']['length_classes'].nil?
  node['deploy-project']['php-oc']['length_classes'].each do |length|
    php_oc_length length['slug'] do
      value length['value']
      description length['description']

      unless length['length_class_id'].nil?
        length_class_id length['length_class_id']
      end
    end
  end
end


unless node['deploy-project']['php-oc']['banners'].nil?
  node['deploy-project']['php-oc']['banners'].each do |banner|
    php_oc_banner banner['name'] do
      status banner['status'] || 1
      force banner['force'] || false
      images banner['banner_image']
    end
  end
end

unless node['deploy-project']['php-oc']['categories'].nil?
  node['deploy-project']['php-oc']['categories'].each do |category|
    php_oc_category category['keyword'] do
      image category['image']
      description category['description']
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

execute "rm -rf #{node['deploy-project']['path']}/system/cache/*" do
  action :run
end