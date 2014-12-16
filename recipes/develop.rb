sharedAlias = 'project_root'

execute "umount #{node['deploy-project']['repo']['path']}" do
  not_if "ls -ld '#{node['deploy-project']['repo']['path']}' | awk '{ print $3; }' | grep '#{node['apache']['user']}' && ls -ld '#{node['deploy-project']['repo']['path']}' | awk '{ print $4; }' | grep '#{node['apache']['user']}'"
end
execute "mount -t vboxsf -o rw,uid=`id -u #{node['apache']['user']}`,gid=`id -g #{node['apache']['user']}` #{sharedAlias} #{node['deploy-project']['repo']['path']}" do
  not_if "ls -ld '#{node['deploy-project']['repo']['path']}' | awk '{ print $3; }' | grep '#{node['apache']['user']}' && ls -ld '#{node['deploy-project']['repo']['path']}' | awk '{ print $4; }' | grep '#{node['apache']['user']}'"
end
