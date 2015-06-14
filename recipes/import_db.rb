if node['deploy-project']['dev']
    include_recipe 'deploy-project::enviroment'

    execute "Import database: #{node['deploy-project']['db']['database']}" do
      fileName = File::expand_path(node['deploy-project']['db']['install'], node['deploy-project']['path'])

      unless File.exist?(fileName)
        throw "File '#{fileName}' doesn't exist."
      end

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


            only_if "[ $(mysql --host='#{node['deploy-project']['db']['host']}' -u#{node['deploy-project']['db']['user']}#{password} -e 'show tables' #{node['deploy-project']['db']['database']} | wc -c) = '0' ]"
            command "#{cat} '#{node['deploy-project']['db']['install']}' | mysql --host='#{node['deploy-project']['db']['host']}' -u#{node['deploy-project']['db']['user']}#{password} #{node['deploy-project']['db']['database']}"
            cwd node['deploy-project']['path']
    end
end
