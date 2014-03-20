define :php_oc_tax_class, :title => nil, :description => nil, :slug => nil, :tax_rule => [] do
  params[:slug] ||= params[:name]
  params[:title] ||= params[:name]
  params[:description] ||= params[:title]

  require 'json'

  geo_zone = {
      title: params[:title],
      description: params[:description],
      slug: params[:slug],
      tax_rule: params[:tax_rule]
  }.to_json

  execute "echo '#{geo_zone}' | php cli/index.php configure/tax_class" do
    command  "echo '#{geo_zone}' | php cli/index.php configure/tax_class"
    cwd node['deploy-project']['path']
    action :run
  end
end