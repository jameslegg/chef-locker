include_recipe 'clocker'

clocker 'hlock-test' do
  lockid 'hlock-test'
  # wait 10 seconds
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end

log 'The lock hlock-test is NOT held by us, this log will not appear' do
  level :warn
  only_if { Clocker.held?('hlock-test', run_context) }
end

clocker 'hlock-test' do
  lockid 'hlock-test'
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockoff
end
