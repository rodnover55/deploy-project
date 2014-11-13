unless node['deploy-project']['hostname'].nil?
  case node['platform']
    when 'debian', 'ubuntu'
      file'/etc/hostname' do
        content node['deploy-project']['hostname']
      end
    when 'redhat', 'centos', 'fedora'
      execute "sed -ie 's/HOSTNAME=.*/HOSTNAME=#{node['deploy-project']['hostname']}/g' /etc/sysconfig/network"
  end
  execute "hostname #{node['deploy-project']['hostname']}"
end

