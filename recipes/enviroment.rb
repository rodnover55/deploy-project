if %w[debian ubuntu].include?(node['platform_family'])
  include_recipe 'apt'
end

case node['platform']
  when 'centos'
    include_recipe 'yum-epel'
end

if !(node['deploy-project']['disabled'] || []).include?('apache-configure')
  include_recipe 'deploy-project::apache'
end

include_recipe 'deploy-project::packages'

if !(node['deploy-project']['disabled'] || []).include?('mysql-configure')
  include_recipe 'deploy-project::mysql'
end