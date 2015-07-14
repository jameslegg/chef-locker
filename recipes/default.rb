#
# Cookbook Name:: clocker
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

be = package 'build-essential' do
  action :nothing
end
be.run_action(:install)

# compile_time is valid but confused by https://github.com/acrmp/foodcritic/issues/339
chef_gem 'zk' do # ~FC009
  action :install
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
