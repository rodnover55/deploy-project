lib_location = 'xdebug.so'

case node['platform']
  when 'redhat', 'centos', 'fedora'
    package 'php-pecl-xdebug' do
      if not node['deploy-project']['old-php']
        options '--enablerepo=remi-php55,remi'
      end
      lib_location = '/usr/lib64/php/modules/xdebug.so'
    end
  when 'debian', 'ubuntu'
    package 'php5-xdebug'
end

dirConfig =
    case node['platform']
      when 'redhat', 'centos', 'fedora'
        '/etc/php.d/'
      when 'debian', 'ubuntu'
        '/etc/php5/mods-available/'
    end

ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == 'inet' }.first
remote_ip = ip.gsub /\.\d+$/, '.1'

template "#{dirConfig}xdebug.ini" do
  source 'php-xdebug.ini.erb'
  variables({
    remote_host: remote_ip,
    lib_location: lib_location
  })
  notifies :reload, 'service[apache2]', :delayed
end

