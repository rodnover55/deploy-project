include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'

unless node['deploy-project']['timezone'].nil?
  configs =
      if node['platform'] == 'centos'
        %w[/etc/php.d/timezone.ini]
      else
        %w[/etc/php5/apache2/conf.d/20-timezone.ini
          /etc/php5/cli/conf.d/20-timezone.ini]
      end
  configs.each do |fn|
    directory ::File.dirname(fn) do
      recursive true
    end
    file fn do
      content "date.timezone = #{node['deploy-project']['timezone']}"
      not_if { node['deploy-project']['timezone'].nil? }
      notifies :restart, 'service[apache2]', :delayed
    end
  end
end

if %w[saucy trusty].include?(node['lsb']['codename'])
  execute 'mcrypt' do
    command 'mv /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/; php5enmod mcrypt'
    only_if { ::File.exist?('/etc/php5/conf.d/mcrypt.ini')}
    notifies :restart, 'service[apache2]', :delayed
  end
  execute 'mcrypt' do
    command 'php5enmod mcrypt'
    notifies :restart, 'service[apache2]', :delayed
  end
end

unless node['deploy-project']['domain'].nil?
  web_app node['deploy-project']['domain'] do
    server_name node['deploy-project']['domain']
    server_aliases node['deploy-project']['aliases']
    docroot File.join(node['deploy-project']['path'], node['deploy-project']['root'])
    allow_override 'All'
    notifies :restart, 'service[apache2]', :delayed
  end
end

if node['deploy-project']['dev']
  include_recipe 'deploy-project::xdebug'
end

file '/etc/apache2/sites-enabled/000-default.conf' do
  action :delete
end