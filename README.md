# clocker (Chef Locker)

A Chef Locking mechanism that uses zookeeper as a backend.

Designed to control chef runs across cluster of machines where changes/restarts
are need to be careful co-ordinated to prevent downtime.

# Requirments

Installs the ZK gem using chef-gem

Needs a zookeeper, but you probably want' a cluster.

# Usage

Use the clocker resource to clockon and clockoff a lock. 

Include the recipe
```
include_recipe 'clocker'
```
Taking a lock (clockon)
```
clocker 'lock-test1' do
  lockid 'lock-test1'
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end
```

For use with other resource that should check a lock before taking action.
Doing some action based on that lock, note you MUST pass run_context as the
2nd argument.
```
log 'The lock lock-test1 exists and is held' do
  level :warn
  only_if { Clocker.held?('lock-test1', run_context) }
end
```

Releasing a lock (clockoff)
```
clocker 'lock-test1' do
  lockid 'lock-test1'
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end
```


