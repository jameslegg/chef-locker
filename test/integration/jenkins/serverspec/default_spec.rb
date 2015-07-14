require 'spec_helper'

describe command('/opt/chef/embedded/bin/gem specification zk') do
  its(:exit_status) { should eq 0 }
end

describe file('/var/run/hlock-test-exists') do
  it { should be_file }
end

describe file('/var/run/hlock-test-notexists') do
  it { should_not be_file }
end

describe file('/var/run/hlock-test-lockexpired') do
  it { should_not be_file }
end
