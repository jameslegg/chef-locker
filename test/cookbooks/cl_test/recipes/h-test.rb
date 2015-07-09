include_recipe 'clocker'

clocker 'hlock-test' do
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end

clocker 'hlock-test' do
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockoff
end
