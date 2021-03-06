unless node['deploy-project']['backup'].nil?
  binary = node['deploy-project']['backup']['bin'] || '/root/bin/backup.sh'
  backup_path = node['deploy-project']['backup']['path'] || '/root/backup'
  log = (node['deploy-project']['backup']['log'].nil?) ? ('> /dev/null 2>&1') :
      (">> '#{node['deploy-project']['backup']['log']}'")

  directory backup_path do
    recursive true
  end

  directory File.dirname(binary) do
    recursive true
  end

  template binary do
    source 'backup.sh.erb'
    mode 700
    variables({
      backup_path: backup_path
    })
  end

  cron 'backup' do
    action :delete
  end

  cron "#{node['deploy-project']['project']} backup" do
    minute node['deploy-project']['backup']['minute'] || Random.rand(59)
    hour node['deploy-project']['backup']['hour'] || Random.rand(23)
    command "#{binary} #{log}"
  end
end
