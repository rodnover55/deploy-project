case node['deploy-project']['type']
  when 'php-wp'
    include_recipe 'deploy-project::php-wp'
  when 'php-oc'
    include_recipe 'deploy-project::php-oc'
  when 'php-cake'
    include_recipe 'deploy-project::php-cake'
end

execute "end configure" do
  command "echo 'End configure'"
  action :run
end
