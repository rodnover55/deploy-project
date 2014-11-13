template '/usr/bin/fakemail.sh' do
  source 'fakemail.sh.erb'
  mode 0755
end

case node['platform']
  when 'debian', 'ubuntu'
    php_fakemail_config_paths =
        %w[etc/php5/apache2/conf.d/50-fakemail.ini
          /etc/php5/cli/conf.d/50-fakemail.ini']
  when 'redhat', 'centos', 'fedora'
    php_fakemail_config_paths = ['/etc/php.d/fakemail.ini']
end

php_fakemail_config_paths.each do |p|
  directory File.dirname(p)
  template p do
    source 'php-fakemail.ini.erb'
    notifies :restart, 'service[apache2]', :delayed
  end
end

directory "/var/mail/sendmail/" do
  mode 0777
end

%w(cur new tmp).each do |d|
  directory "/var/mail/sendmail/#{d}" do
    mode 0777
  end
end