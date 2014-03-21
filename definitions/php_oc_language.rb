define :php_oc_language, :code => nil, :locale => nil, :image => nil,
       :directory => nil, :filename => nil do
  if params[:code].nil? || params[:locale].nil? || params[:image].nil? ||
      params[:directory].nil? || params[:filename].nil?
    raise 'Set required params'
  end

  require 'json'

  language = {
      name: params[:name],
      code: params[:code],
      locale: params[:locale],
      image: params[:image],
      directory: params[:directory],
      filename: params[:filename]
  }.to_json

  execute "echo '#{language}' | php cli/index.php configure/language" do
    cwd node['deploy-project']['path']
    action :run
  end
end