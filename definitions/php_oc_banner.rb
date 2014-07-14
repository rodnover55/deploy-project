define :php_oc_banner, :images => nil, :status => 1, :force => false do
  require 'json'

  banner = {
      name: params[:name],
      status: params[:status],
      banner_image: params[:images]
  }.to_json.gsub('\'', '\\\\047')

  cmd = "/bin/echo -e '#{banner}' | php cli/index.php banner/save"
  if params[:force]
    cmd += ' --force'
  end


  execute cmd do
    cwd node['deploy-project']['path']
    action :run
  end

end