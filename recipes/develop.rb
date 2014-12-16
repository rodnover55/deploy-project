sharedAlias = 'project_root'

execute "umount #{node['deploy-project']['path']}" do
  not_if "ls -ld '#{node['deploy-project']['path']}' | awk '{ print $3; }' | grep '#{node['apache']['user']}' && ls -ld '#{node['deploy-project']['path']}' | awk '{ print $4; }' | grep '#{node['apache']['user']}'"
end
execute "mount -t vboxsf -o rw,uid=`id -u #{node['apache']['user']}`,gid=`id -g #{node['apache']['user']}` #{sharedAlias} #{node['deploy-project']['path']}" do
  not_if "ls -ld '#{node['deploy-project']['path']}' | awk '{ print $3; }' | grep '#{node['apache']['user']}' && ls -ld '#{node['deploy-project']['path']}' | awk '{ print $4; }' | grep '#{node['apache']['user']}'"
end
