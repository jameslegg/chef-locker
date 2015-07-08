# Include clocker to get the zk gem
include_recipe 'clocker'

if Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-A',
                         node['hostname'])
  log "INCORRECT: did not take Lock A"
else
  log "CORRECT: Taken Lock A"
end

# try and take the lock again wait 2 seconds, retry 3 times
if Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-A',
                         node['hostname'], 2, 3)
  log "CORRECT: did not take Lock A as it was already taken"
else
  log "INCORRECT: Took Lock A again"
end

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testlock-A')
  log "CORRECT: Lock A exists"
else
  log "INCORRECT: Lock A does not exist"
end

Clocker::Lock.clockoff('clocker_zookeeper_1:2181', 'testlock-A',
                       node['hostname'])

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testlock-B')
  log "INCORRECT: Lock B exists"
else
  log "CORRECT: Lock B does not exist"
end

Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-C',
                      'fake-node-hostname')

# Should be unable to remove this lock as it's not the owner
if Clocker::Lock.clockoff('clocker_zookeeper_1:2181', 'testlock-C',
                          node['hostname'])
  log "INCORRECT: Lock C was unlocked, but I'm no the owner"
else
  log "CORRECT: Lock C was left locked, because I'm not the owner"
end

# Force the removal of testlock-C
if Clocker::Lock.flockoff('clocker_zookeeper_1:2181', 'testlock-C')
  log "CORRECT: Lock C was forcibly unlocked"
else
  log "INCORRECT: Lock C was unable to be forcibly unlocked"
end

if Clocker::Lock.exists?('clocker_zookeeper_1:2181', 'testLock-C')
  log "INCORRECT: Lock C exists"
else
  log "CORRECT: Lock C does not exist"
end
