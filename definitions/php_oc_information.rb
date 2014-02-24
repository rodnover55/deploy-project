define :php_oc_information, :keyword => nil, :template => nil, :title => nil, :sort_order => 0,
       :bottom => 1, :status => 1, :force => false do
  if params[:keyword].nil? || params[:title].nil?
    raise 'Set required params'
  end
  params[:template] ||= params[:name]

  if params[:force]
    execute "php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}'" do
      command "php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}'"
      cwd node['deploy-project']['path']
      action :run
    end
  else
    ruby_block "php cli/index.php configure/information_check '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}'" do
      not_if "cd '#{node['deploy-project']['path']}'; php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}'"
      block { raise "Information not equal"}
      action :run
    end
  end
end