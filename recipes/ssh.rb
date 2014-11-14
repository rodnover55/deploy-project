unless node['deploy-project']['ssh']['keydir'].nil?
  include_recipe 'apache2'

  package 'git'

  directory "Creating #{node['deploy-project']['ssh']['keydir']}.ssh" do
    recursive true
    path "#{node['deploy-project']['ssh']['keydir']}.ssh"
    owner node['apache']['user']
    group node['apache']['group']
    mode 00700
  end

  execute "cp #{node['deploy-project']['repo']['private_key']} #{node['deploy-project']['ssh']['keydir']}.ssh/id_rsa" do
    umask 00700
  end

  execute "cp #{node['deploy-project']['repo']['public_key']} #{node['deploy-project']['ssh']['keydir']}.ssh/id_rsa.pub" do
    umask 00700
  end

  execute "chown -R #{node['apache']['user']}:#{node['apache']['group']} '#{node['deploy-project']['ssh']['keydir']}.ssh/'"
  execute "chmod -R 700 '#{node['deploy-project']['ssh']['keydir']}.ssh/'"

  template "#{node['deploy-project']['ssh']['keydir']}wrap-ssh4git.sh" do
    source 'wrap-ssh4git.sh.erb'
    mode 00700
    owner node['apache']['user']
    group node['apache']['group']
    variables({key: "#{node['deploy-project']['ssh']['keydir']}.ssh/id_rsa" })
  end
end