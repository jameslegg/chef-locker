class Chef::Recipe::Clocker
  # Our wrapper around the functionality in ZK gem
  class Zk
    attr_accessor :zkconn

    def initialize(server)
      @zkconn = ZK.new(server)
    end

    # check lock
    def exists?(lock_id)
      zkconn.stat("/clocker-#{lock_id}").exists?
    end

    # set a lock sleep wait seconds between retries
    def clockon(lock_id, chef_node, wait, retries)
      puts "clocking on #{lock_id}"
      zkconn.create("/clocker-#{lock_id}", chef_node) unless
        zkconn.exists?("/clocker-#{lock_id}")
      lock = nil
      while retries && retries > 0 && !lock
        msg = "clocker lock #{lock_id} already exists "
        msg << "#{retries} retries left, waiting #{wait} seconds"
        Chef::Log.info(msg)
        puts msg
        puts "sleeping a bit"
        sleep(wait)
        unless zkconn.exists?("/clocker-#{lock_id}")
          lock = zkconn.create("/clocker-#{lock_id}", chef_node)
        end
        retries -=1
      end
      return lock
    end

    # release lock (if we are the owner)
    def clockoff(lock_id, chef_node)
      if zkconn.stat("/clocker-#{lock_id}").exists?
        if glock("#{lock_id}") == chef_node
          zkconn.delete("/clocker-#{lock_id}")
          return true
        end
      else
        return false
      end
    end

    # force the release lock
    def flockoff(lock_id)
      if zkconn.stat("/clocker-#{lock_id}").exists?
        zkconn.delete("/clocker-#{lock_id}")
        return true
      else
        return false
      end
    end

    # get lock info
    def glock(lock_id)
      if zkconn.stat("/clocker-#{lock_id}").exists?
        info = zkconn.get("/clocker-#{lock_id}")
        info[0]
      end
    end

    def close
      zkconn.close!
    end
  end

  # Provide ability to use chef locks from a recipe
  class Lock
    def self.clock?(zk_host, lock_id)
      status =Zk.new(zk_host).exists?(lock_id)
      msg = "clocker lock #{lock_id} exists on #{zk_host}"
      Chef::Log.info(msg)
      status
    end

    def self.clockon(zk_host, lock_id, chef_node, wait = nil, retries = nil)
      if Zk.new(zk_host).exists?(lock_id)
        msg = "clocker lock #{lock_id} id: #{chef_node} allready exists"
        msg << " on #{zk_host} waiting for #{wait} retrying #{retries}"
        Zk.new(zk_host).clockon(lock_id, chef_node, wait, retries)
        Chef::Log.info(msg)
        return false
      else
        Zk.new(zk_host).clockon(lock_id, chef_node, wait, retries)
        msg = "clocker lock #{lock_id} id: #{chef_node} obtained on #{zk_host}"
        Chef::Log.info(msg)
        return true
      end
    end

    def self.clockoff(zk_host, lock_id, chef_node)
      if Zk.new(zk_host).clockoff(lock_id, chef_node)
        msg = "clocker lock #{lock_id} id: #{chef_node} removed from #{zk_host}"
        Chef::Log.debug(msg)
      else
        owner = Zk.new(zk_host).glock(lock_id)
        Chef::Log.warn("Unable to remove: #{lock_id}, owned by: #{owner}")
        return false
      end
    end

    # force a lock removal
    def self.flockoff(zk_host, lock_id)
      if Zk.new(zk_host).flockoff(lock_id)
        msg = "clocker lock #{lock_id} forcibly removed"
        msg << "from #{zk_host}"
        Chef::Log.warn(msg)
      else
        Chef::Log.error("Unable to force removal of: #{lock_id}!")
      end
    end
  end
end
