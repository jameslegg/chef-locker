# Include clocker to get the zk gem
include_recipe 'clocker'

if Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-A',
                         node['hostname'])
  log "INCORRECT: did not take Lock A"
else
  log "CORRECT: Taken Lock A"
end

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testlock-A')
  log "CORRECT: Lock A exists"
else
  log "INCORRECT: Lock A does not exist"
end

Clocker::Lock.clockoff('clocker_zookeeper_1:2181', 'testlock-B',
                       node['hostname'])

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testlock-B')
  log "INCORRECT: Lock A exists"
else
  log "CORRECT: Lock A does not exist"
end

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testLock-B')
  log "INCORRECT: Lock B exists"
else
  log "CORRECT: Lock B does not exist"
end

Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-C',
                      'fake-node-hostname')

# Should be unable to remove this lock as it's not the owner
if Clocker::Lock.clockoff('clocker_zookeeper_1:2181', 'testlock-C',
                          node['hostname'])
  log "INCORRECT: Lock C was unlocked"
else
  log "CORRECT: Lock C was not unlocked"
end

# Should be unable to remove this lock as it's not the owner
if Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-C',
                         node['hostname'])
  log "INCORRECT: Lock C was taken by another system"
else
  log "CORRECT: Lock C was no taken"
end

# Force the removal of testlock-C
if Clocker::Lock.flockoff('clocker_zookeeper_1:2181', 'testlock-C')
  log "CORRECT: Lock C was forcibly unlocked"
else
  log "INCORRECT: Lock C was not forcibly unlocked"
end

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testLock-C')
  log "INCORRECT: Lock C exists"
else
  log "CORRECT: Lock C does not exist"
end
