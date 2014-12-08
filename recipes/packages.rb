if node['deploy-project']['old-php'] and %w[centos].include?(node['platform'])
  include_recipe 'deploy-project::centos-php55'
end


if %w[debian ubuntu].include?(node['platform_family'])
  include_recipe 'apt'
end

case node['platform']
  when 'centos'
    if not node['deploy-project']['old-php']
      include_recipe 'yum-epel'
    end
end

packages =
  case node['platform']
    when 'debian', 'ubuntu'
      %w[mysql-server php5 mysql-client php5-json php5-mcrypt
        php5-curl php5-gd php5-mysql screen git wget ruby-dev]
    when 'redhat', 'centos', 'fedora'
      %w[mysql-server php mysql php-mcrypt php-curl php-mbstring
        php-gd php-mysql screen git php-domxml php-soap wget]
  end

packages.each do |p|
  package p
  if node['deploy-project']['old-php'] and %w[centos].include?(node['platform'])
    options '--enablerepo=remi-php55,remi'
  end
end
