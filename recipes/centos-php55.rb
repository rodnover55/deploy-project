include_recipe 'deploy-project::ssh'

remote_file "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm" do
  source 'http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm'
  not_if { ::File::exist?('/etc/yum.repos.d/epel.repo') ||
      ::File::exist?("#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm") }
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/remi-release-6.rpm" do
  source 'http://rpms.famillecollet.com/enterprise/remi-release-6.rpm'
  not_if { ::File::exist?('/etc/yum.repos.d/remi.repo') ||
      ::File::exist?("#{Chef::Config[:file_cache_path]}/remi-release-6.rpm") }
  action :create
end

rpm_package "epel-repo" do
  source "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm"
  not_if { ::File::exist?('/etc/yum.repos.d/epel.repo') }
  action :install
end

rpm_package "remi-repo" do
  source "#{Chef::Config[:file_cache_path]}/remi-release-6.rpm"
  not_if { ::File::exist?('/etc/yum.repos.d/remi.repo') }
  action :install
end
