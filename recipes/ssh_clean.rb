directory "Deleting #{node['deploy-project']['ssh']['keydir']}" do
  path node['deploy-project']['ssh']['keydir']
  recursive true
  action :delete
end
