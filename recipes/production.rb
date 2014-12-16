directory node['deploy-project']['repo']['path'] do
  owner node['apache']['user']
  group node['apache']['group']
end

git "Cloning repo #{node['deploy-project']['repo']['path']}" do
  destination node['deploy-project']['repo']['path']
  enable_submodules true
  user node['apache']['user']
  group node['apache']['group']
  repository node['deploy-project']['repo']['url']
  revision node['deploy-project']['repo']['branch']
  action node['deploy-project']['repo']['method']
  ssh_wrapper "#{node['deploy-project']['ssh']['keydir']}wrap-ssh4git.sh"
  #depth 1
end

execute "chown -R #{node['apache']['user']}:#{node['apache']['group']} '#{node['deploy-project']['repo']['path']}'"