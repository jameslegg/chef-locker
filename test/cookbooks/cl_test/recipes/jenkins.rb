include_recipe 'clocker'

clocker 'hlock-test' do
  lockid 'hlock-test'
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end

# This file shuld get created
file '/var/run/hlock-test-exists' do
  only_if { Clocker.held?('hlock-test', run_context) }
end

# This file shuld not get created
file '/var/run/hlock-fake-notexists' do
  only_if { Clocker.held?('hlock-fake', run_context) }
end

clocker 'hlock-test' do
  lockid 'hlock-test'
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockoff
end

# This file should not get created
file '/var/run/hlock-test-lock-expired' do
  only_if { Clocker.held?('hlock-test', run_context) }
end
