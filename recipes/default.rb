include_recipe 'deploy-project::enviroment'
key_dir = '/tmp/deploy/'
directory "#{key_dir}.ssh" do
  recursive true
  owner node['apache']['user']
  group node['apache']['group']
  mode 00700
end

file "#{key_dir}.ssh/id_rsa" do
  content node['deploy-project']['repo']['private_key']
  owner node['apache']['user']
  group node['apache']['group']
  mode 00700
end

file "#{key_dir}.ssh/id_rsa.pub" do
  content node['deploy-project']['repo']['public_key']
  owner node['apache']['user']
  group node['apache']['group']
  mode 00700
end

template "{key_dir}wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh.erb"
  mode 00700
  owner node['apache']['user']
  group node['apache']['group']
  variables({key: "#{key_dir}.ssh/id_rsa" })
end

file

deploy "private_repo" do
  repository node['deploy-project']['repo']['url']
  branch node['deploy-project']['repo']['branch'] || 'master'
  user node['apache']['user']
  group node['apache']['group']
  deploy_to node['deploy-project']['path']
  action :deploy
  ssh_wrapper "#{key_dir}wrap-ssh4git.sh"
end


include_recipe 'deploy-project::configure'
