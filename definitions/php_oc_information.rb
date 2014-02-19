define :php_oc_information, :keyword => nil, :template => nil, :title => nil, :sort_order => 0,
       :bottom => 1, :status => 1 do
  if params[:keyword].nil? || params[:title].nil?
    raise 'Set required params'
  end
  params[:template] ||= params[:name]
  execute "php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}'" do
    command "php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}'"
    cwd node['deploy-project']['path']
    action :run
  end
end