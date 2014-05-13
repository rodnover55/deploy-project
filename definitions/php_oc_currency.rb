define :php_oc_currency, :code => nil, :title => nil, :symbol_left => nil,
       :symbol_right => nil, :decimal_place => nil, :value => 1.0, :status => 1 do
  if params[:title].nil? || params[:value].nil?
    raise 'Set required params'
  end

  params[:code] ||= params[:name]

  require 'json'

  currency = {
      title: params[:title],
      code: params[:code],
      symbol_left: params[:symbol_left],
      symbol_right: params[:symbol_right],
      decimal_place: params[:decimal_place],
      value: params[:value],
      status: params[:status]
  }.to_json

  execute "echo '#{currency}' | php cli/index.php currency" do
    cwd node['deploy-project']['path']
    action :run
  end
end