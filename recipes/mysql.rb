include_recipe 'database::mysql'

service_mysql = (node['platform'] == 'centos') ? ('service[mysqld]') : ('service[mysql]')

service (node['platform'] == 'centos') ? ('mysqld') : ('mysql') do
  action [:start]
end

if %w(redhat centos fedora).include?(node['platform'])
  directory '/etc/my.cnf.d'
  if node['deploy-project']['dev']
    template '/etc/my.cnf.d/dev.cnf' do
      source 'mysql-custom-dev.cnf.erb'
      only_if { node['platform'] == 'centos' }
      notifies :restart, service_mysql, :delayed
    end
  end
  template '/etc/my.cnf.d/custom.cnf' do
    source 'mysql-custom.cnf.erb'
    only_if { node['platform'] == 'centos' }
    notifies :restart, service_mysql, :delayed
  end
else
  directory '/etc/mysql/conf.d' do
    recursive true
  end
  if node['deploy-project']['dev']
    template '/etc/mysql/conf.d/dev.cnf' do
      source 'mysql-custom-dev.cnf.erb'
      notifies :restart, service_mysql, :delayed
    end
  end
  template '/etc/mysql/conf.d/custom.cnf' do
    source 'mysql-custom.cnf.erb'
    notifies :restart, service_mysql, :delayed
  end
end

unless node['deploy-project']['domain'].nil?
  if node['deploy-project']['db']['force-config']
    mysql_database "Force drop #{node['deploy-project']['project']}" do
      connection(
          host: node['deploy-project']['db']['host'],
          username: node['deploy-project']['db']['user'],
          password: node['deploy-project']['db']['password'],
      )
      database_name node['deploy-project']['db']['project']
      action :drop
    end
  end

  mysql_database "Create database #{node['deploy-project']['database']}" do
    connection(
        host: node['deploy-project']['db']['host'],
        username: node['deploy-project']['db']['user'],
        password: node['deploy-project']['db']['password'],
    )
    database_name node['deploy-project']['db']['database']
    action :create
  end
end

if node['deploy-project']['dev']
  mysql_database_user "#{node['deploy-project']['db']['user']}" do
    connection(
        :host     => node['deploy-project']['db']['host'],
        :username => node['deploy-project']['db']['user'],
        :password => node['deploy-project']['db']['password']
    )
    password node['deploy-project']['db']['password']
    host '%'
    action :grant
  end
end