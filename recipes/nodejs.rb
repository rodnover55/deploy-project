include_recipe 'nodejs'

execute 'Install global npm packages' do
  command 'npm install -g grunt-cli bower phantomjs'
end

frontendPath = File.join(node['deploy-project']['repo']['path'], 
	node['deploy-project']['frontend']['root'])

execute 'Install npm packages' do
  command 'npm install'
  cwd frontendPath
  user node['apache']['user']
  group node['apache']['group']
  environment({'HOME' => frontendPath})
end


