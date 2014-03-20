define :php_oc_tax_rate, :tax_rate_name => nil, :rate => nil, :type => nil, :slug => nil, :geo_zone => nil do
  if params[:rate].nil? ||  params[:type].nil? || params[:geo_zone].nil?
    raise 'Set required params'
  end

  params[:slug] ||= params[:name]
  params[:tax_rate_name] ||= params[:name]

  require 'json'

  geo_zone = {
      name: params[:tax_rate_name],
      rate: params[:rate],
      type: params[:type],
      slug: params[:slug],
      geo_zone: params[:geo_zone]
  }.to_json

  execute "echo '#{geo_zone}' | php cli/index.php configure/tax_rate" do
    command  "echo '#{geo_zone}' | php cli/index.php configure/tax_rate"
    cwd node['deploy-project']['path']
    action :run
  end
end