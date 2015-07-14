 clocker (Chef Locker) Cookbook
===============================

A Chef Locking mechanism that uses zookeeper as a backend.

Designed to control chef runs across cluster of machines where changes/restarts
need to be done by a single node at a time.

Requirments
----------
- Installs the ZK gem using chef-gem
- A Zookeeper, but you probably want a cluster of zookeepers.

Overview
--------

Locks are taken out using the clocker resource.

After you obtain a lock you MUST use the Clocker.held? method with a guard on
all resources that you want to prevent running when you don't hold the lock.

If you Chef run crashes the connection to zookeeper will close and your locks
will be cleared up.  Please see the documentation of the [ZK](http://www.rubydoc.info/gems/zk/ZK/Locker/ExclusiveLocker) gem
for implementation details.

Usage
------

Use the clocker resource to clockon and clockoff a lock. 

### Include the recipe
```
include_recipe 'clocker'
```

Resource/Provider
----------------
### clocker

Taking a lock (clockon action)
```
clocker 'lock-test1' do
  lockid 'lock-test1'
  lockwait 10
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end
```

Releasing a lock (clockoff action)
```
clocker 'lock-test1' do
  lockid 'lock-test1'
  zookeeper 'clocker_zookeeper_1:2181'
  action :clockon
end
```

### Clocker.held?
Method for use with other resource that should check the status of a lock before
any changes are made. Please note that you MUST pass run_context as the 2nd arg.

```
log 'The lock lock-test1 exists and is held' do
  level :warn
  only_if { Clocker.held?('lock-test1', run_context) }
end
```

Development
----------
A docker-compose file is included that will launch a zookeeper docker.
A test kitchen configuration is included that will link docker containers to
the zookeeper docker on launch. 

Currently development is done using the following methodology:

```
docker-compose up
kitchen converge cl-test-ubuntuA
# the cl-test will sleep for 300 seconds
kitchen converge inuse
# verifies it is unable to take the same lock as the sleeping cl-test suite
```
