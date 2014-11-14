include_recipe 'deploy-project::packages'

if !(node['deploy-project']['disabled'] || []).include?('apache-configure')
  include_recipe 'deploy-project::apache'
end


if !(node['deploy-project']['disabled'] || []).include?('mysql-configure')
  include_recipe 'deploy-project::mysql'
end