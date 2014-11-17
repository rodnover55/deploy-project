execute "Import database: #{node['deploy-project']['db']['database']}" do
  cat = case ::File.extname(node['deploy-project']['db']['install'])
          when '.gz'
            'zcat'
          else
            'cat'
        end

  password =
      if node['deploy-project']['db']['password'].nil? || (node['deploy-project']['db']['password'] == '')
        ''
      else
        " -p#{node['deploy-project']['db']['password']}"
      end

  not_if "mysql --host='#{node['deploy-project']['db']['host']}' -u#{node['deploy-project']['db']['user']}#{password} -e 'show tables' #{node['deploy-project']['db']['database']} | grep 'virus'"
  command "#{cat} '#{node['deploy-project']['path']}/#{node['deploy-project']['db']['install']}' | mysql --host='#{node['deploy-project']['db']['host']}' -u#{node['deploy-project']['db']['user']}#{password} #{node['deploy-project']['db']['database']}"
  cwd node['deploy-project']['path']
end