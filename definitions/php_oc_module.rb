define :php_oc_module, :module => nil, :action => nil, :config => nil do
  if %w{install uninstall}.include?(params[:action])
    raise 'Set required params'
  end
  params[:module] ||= params[:name]
  execute "php cli/index.php configure/module '#{params[:action]}' '#{params[:module]}'" do
    command "php cli/index.php configure/module '#{params[:action]}' '#{params[:module]}'"
    cwd node['deploy-project']['path']
    action :run
  end
end