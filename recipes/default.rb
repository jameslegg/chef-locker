#
# Cookbook Name:: clocker
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

be = package 'build-essential' do
  action :nothing
end
be.run_action(:install)

chef_gem 'zk' do
  action :install
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end

require 'zk'
