define :php_oc_information, :keyword => nil, :template => nil, :title => nil, :sort_order => 0,
       :bottom => 1, :status => 1, :force => false, :id => '' do
  if params[:keyword].nil? || params[:title].nil?
    raise 'Set required params'
  end
  params[:template] ||= params[:name]

  if params[:force]
    execute "php cli/index.php configure/information '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}' #{params[:id]}" do
      cwd node['deploy-project']['path']
      action :run
    end
  # else
  #   execute "php cli/index.php configure/information_check '#{params[:keyword]}' '#{params[:template]}' '#{params[:title]}' '#{params[:sort_order]}' '#{params[:bottom]}' '#{params[:status]}' #{params[:id]}" do
  #     cwd node['deploy-project']['path']
  #     returns [0]
  #     action :run
  #   end
  end
end