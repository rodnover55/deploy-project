define :php_oc_customer_group, :slug => nil, :approval => 1, :sort_order => 0, :discount => 0,
       :discount_minimum => 0, :description => nil do
  if params[:description].nil?
    raise 'Set required params'
  end
  params[:slug] ||= params[:name]

  require 'json'

  description = {
      slug: params[:slug],
      approval: params[:approval],
      sort_order: params[:sort_order],
      discount: params[:discount],
      discount_minimum: params[:discount_minimum],
      description: params[:description]
  }.to_json

  execute "echo '#{description}' | php cli/index.php customer/save_group" do
    cwd node['deploy-project']['path']
    action :run
  end
end