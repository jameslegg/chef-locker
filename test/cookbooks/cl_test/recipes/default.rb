# Include clocker to get the zk gem
include_recipe 'clocker'
if Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-A',
                         node['hostname'])
  log "CORRECT: Taken Lock A"
else
  log "INCORRECT: did not take Lock A"
end

# try and take the lock again wait 2 seconds, retry 3 times
if Clocker::Lock.clockon('clocker_zookeeper_1:2181', 'testlock-A',
                         node['hostname'], 2, 3)
  log "INCORRECT: Took Lock A again"
else
  log "CORRECT: did not take Lock A as it was already taken"
end

if Clocker::Lock.clock?('clocker_zookeeper_1:2181', 'testlock-A')
  log "CORRECT: Lock A exists"
else
  log "INCORRECT: Lock A does not exist"
end

Clocker::Lock.clockoff('clocker_zookeeper_1:2181', 'testlock-A',
                       node['hostname'])

if Clocker::Lock.clock?('clocker_zookeeper_1:2181', 'testlock-B')
  log "INCORRECT: Locklock B exists"
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

if Clocker::Lock.clock?('clocker_zookeeper_1:2181', 'testlock-C')
  log "INCORRECT: Lock C exists"
else
  log "CORRECT: Lock C does not exist"
end
