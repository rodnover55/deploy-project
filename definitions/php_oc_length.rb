define :php_oc_length, :slug => nil, :length_class_id => nil, :value => nil, :description => nil do
  if params[:description].nil?
    raise 'Set required params'
  end
  params[:slug] ||= params[:name]

  require 'json'

  description_data = {
      slug: params[:slug],
      value: params[:value],
      description: params[:description]
  }

  unless params[:length_class_id].nil?
    description_data.merge!({length_class_id: params[:length_class_id]})
  end

  description = description_data.to_json

  execute "echo '#{description}' | php cli/index.php length/save" do
    cwd node['deploy-project']['path']
    action :run
  end

end