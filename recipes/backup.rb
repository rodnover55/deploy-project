unless node['deploy-project']['backup'].nil?
  binary = node['deploy-project']['backup']['bin'] || '/root/bin'
  backup_path = node['deploy-project']['backup']['path'] || '/root/backup'
  backup = "#{binary}/backup.sh"
  log = (node['deploy-project']['backup']['log'].nil?) ? ('> /dev/null 2>&1') :
      (">> '#{node['deploy-project']['backup']['log']}'")

  directory backup_path do
    recursive true
  end

  directory binary do
    recursive true
  end

  template backup do
    source 'backup.sh.erb'
    mode 700
    variables({
      backup_path: backup_path
    })
  end

  cron "backup" do
    minute Random.rand(59)
    hour Random.rand(23)
    command "#{backup} #{log}"
  end
end