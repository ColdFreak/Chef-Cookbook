#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "apache2" do
    action :install
end

# second resource, the 'service resource
service "apache2" do
    action [:enable, :start]
end

template "/var/www/html/index.html" do
    source "index.html.erb"
    mode "0644"
end
