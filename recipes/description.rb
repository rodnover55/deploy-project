file "#{node['deploy-project']['path']}/a2description" do
  content node['deploy-project']['description'] || node['deploy-project']['path']
end