define :php_oc_geo_zone, :geo_zone_name => nil, :description => nil, :slug => nil, :zones => [] do
  params[:slug] ||= params[:name]

  require 'json'

  geo_zone = {
      name: params[:geo_zone_name],
      decription: params[:description],
      slug: params[:slug],
      zone_to_geo_zone: params[:zones]
  }.to_json

  execute "echo '#{geo_zone}' | php cli/index.php configure/geo_zone" do
    command  "echo '#{geo_zone}' | php cli/index.php configure/geo_zone"
    cwd node['deploy-project']['path']
    action :run
  end
end