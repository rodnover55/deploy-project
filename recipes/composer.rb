composer '/usr/bin' do
  owner 'root'
  action [:install]
end

composer_project 'lah' do
  run_as node['apache']['user']
  install_path '/usr/bin'
  action [:install]
  dev true
  project_dir "#{node['deploy-project']['repo']['path']}"
end