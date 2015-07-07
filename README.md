# clocker (Chef Locker)

A rudimentary Chef Locking mechanism that uses zookeeper as a backend.

Designed to control chef runs across cluster of machines where changes/restarts
are need to be careful co-ordinated to prevent downtime.

# Requirments

Installs the ZK gem using chef-gem

Needs a zookeeper(s)!

# Usage

Include the recipe
```
include_recipe 'clocker'
```

By convention it's best to provide the real chef nodename to clockon and
clockoff to identify which chef node takes the lock and ensure the same node
releases it. This isn't enforce so you can provide anything but it wil break
some of the safety features.

```
if Clocker::Lock.clockon('myzookeeper:2181', 'foo_cluster_lock',
                         node['hostname'])
  service 'foo_cluster' do
    action: restart, :immediately
  end
  Clocker::Lock.clockoff('myzookeeper', 'foo_cluster_lock', node['hostname'])
else
  log "Can't restart the foo cluster right now, someone has the lock"
end
```

If your lock is not available AND you understand the consequences of 
over-riding it is possible to forcibly remove any Chef locks.

```
Clocker::Lock.flockoff('myzookeeper:2181','foo_cluster_lock')
```

It is possible to check if a lock exists

```
Clocker::Lock.exists('myzookeeper:2181','foo_cluster_lock')
```
