include_recipe 'clocker'

clocker 'hlock-test' do
  lockid 'hlock-test'
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end

log 'The lock hlock-test exists and is held' do
  level :warn
  only_if { Clocker.held?('hlock-test', run_context) }
end

log 'Then hlock-fake lock does not exist, this log message will not appear' do
  level :warn
  only_if { Clocker.held?('hlock-fake', run_context) }
end

clocker 'hlock-test' do
  lockid 'hlock-test'
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockoff
end

log 'The lock hlock-test is no longer held, this message will not appear' do
  level :warn
  only_if { Clocker.held?('hlock-test', run_context) }
end

