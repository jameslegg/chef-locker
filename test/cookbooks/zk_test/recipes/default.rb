include_recipe 'zookeeper::default'

service 'zookeeper' do
  action [ :enable, :start ]
end
