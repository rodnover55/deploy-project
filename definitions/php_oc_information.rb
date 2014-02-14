define :php_oc_information, :keyword => nil, :template => nil, :title => nil do
  if params[:keyword].nil? || params[:title].nil?
    raise 'Set required params'
  end
  params[:template] ||= params[:name]
  execute "php oc template #{params[:title]}" do
    command "php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}'"
    cwd node['deploy-project']['path']
  end
end