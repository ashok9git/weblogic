
domain_home_dirs = [
  "#{node['weblogic']['domain_home'}",
  "#{node['weblogic']['domain_home']}/#{node['weblogic']['domain_name']}",
]

domain_home_dirs.each do |dirname|
  directory dirname do
    owner node['weblogic']['user'] 
    group node['weblogic']['group'] 
    mode 00755
    action :create
  end
end

# directory node['weblogic']['domain_home'] do
#   owner node['weblogic']['user'] 
#   group node['weblogic']['group'] 
#   mode 00755
#   action :create
# end

# directory "#{node['weblogic']['domain_home']}/#{node['weblogic']['domain_name']}" do
#   owner node['weblogic']['user'] 
#   group node['weblogic']['group'] 
#   mode 00755
#   action :create
# end

template "#{node['weblogic']['domain_home']}/create_#{node[:weblogic][:domain_name]}_domain.py" do
  source "create_domain.py.erb"
  owner node['weblogic']['user'] 
  group node['weblogic']['group'] 
  mode "0755"
end

execute "wlst.sh create_#{node['weblogic']['domain_name']}_domain.py" do
  command "#{node['weblogic']['wls_install_dir']}/common/bin/wlst.sh #{Chef::Config['file_cache_path']}/create_#{node['weblogic']['domain_name']}_domain.py"
  creates "#{node['weblogic']['domain_home']}/#{node['weblogic']['domain_name']}/bin"
  user node['weblogic']['user'] 
  group node['weblogic']['group'] 
  action :run
end

template "/etc/init.d/weblogic" do
  source "weblogic_init.d.sh.erb"
  owner "root"
  group "root"
  mode "0744"
end

service "weblogic" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
