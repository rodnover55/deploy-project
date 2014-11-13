include_recipe 'deploy-project::ssh'

include_recipe 'deploy-project::enviroment'

if node['deploy-project']['dev']
  include_recipe 'deploy-project::develop'
else
  include_recipe 'deploy-project::production'
end

include_recipe 'deploy-project::ssh_clean'