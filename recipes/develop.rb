include_recipe 'deploy-project::enviroment'
case node['deploy-project']['type']
  when 'php-wp'
    include_recipe 'deploy-project::php-wp'
  when 'php-oc'
    include_recipe 'deploy-project::php-oc'
end