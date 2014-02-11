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

template "#{key_dir}wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh.erb"
  mode 00700
  owner node['apache']['user']
  group node['apache']['group']
  variables({key: "#{key_dir}.ssh/id_rsa" })
end

if node['deploy-project']['repo']['erase_path']
  directory node['deploy-project']['path'] do
    owner node['apache']['user']
    group node['apache']['group']
    action node['deploy-project']['repo']['method']
    recursive true
  end
end

directory node['deploy-project']['path'] do
  owner node['apache']['user']
  group node['apache']['group']
end

git node['deploy-project']['path'] do
  destination node['deploy-project']['path']
  enable_submodules true
  user node['apache']['user']
  group node['apache']['group']
  repository node['deploy-project']['repo']['url']
  revision node['deploy-project']['repo']['branch'] || 'master'
  action :export
  ssh_wrapper "#{key_dir}wrap-ssh4git.sh"
  depth 1
end


include_recipe 'deploy-project::configure'
