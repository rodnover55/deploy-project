sharedAlias = 'project_root'

directory node['deploy-project']['path'] do
  owner node['apache']['user']
  group node['apache']['group']
end

execute "umount #{node['vdna']['path']}" do
  not_if "ls -ld '#{node['vdna']['path']}' | awk '{ print $3; }' | grep '#{node['apache']['user']}' && ls -ld '#{node['vdna']['path']}' | awk '{ print $4; }' | grep '#{node['apache']['user']}'"
end
execute "mount -t vboxsf -o rw,uid=`id -u #{node['apache']['user']}`,gid=`id -g #{node['apache']['user']}` #{sharedAlias} #{node['vdna']['path']}" do
  not_if "ls -ld '#{node['vdna']['path']}' | awk '{ print $3; }' | grep '#{node['apache']['user']}' && ls -ld '#{node['vdna']['path']}' | awk '{ print $4; }' | grep '#{node['apache']['user']}'"
end
