case node['platform']
  when 'redhat', 'centos', 'fedora'
    package 'php-pecl-xdebug'
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
  variables({remote_host: remote_ip})
  notifies :reload, 'service[apache2]', :delayed
end

