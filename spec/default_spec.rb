#
# Cookbook Name:: clocker
# Spec:: default
#
# Copyright (c) 2015 James Legg

require 'spec_helper'

describe 'clocker::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'installs zk gem' do
      expect(chef_run).to install_chef_gem('zk')
    end

    it 'installs build essentials' do
      expect(chef_run).to install_package('build-essential')
    end
  end
end
