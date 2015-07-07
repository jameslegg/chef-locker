class Chef::Recipe::Clocker
  class Zk
    attr_accessor :zkconn

    def initialize(server)
      @zkconn = ZK.new(server)
    end

    # check lock
    def clock?(lock_id, chef_node)
      zkconn.stat("/clocker-#{lock_id}").exists?
    end

    # set lock
    def clockon(lock_id, chef_node)
      zkconn.create("/clocker-#{lock_id}", chef_node)
    end

    # release lock (if we are the owner)
    def clockoff(lock_id, chef_node)
      if zkconn.stat("/clocker-#{lock_id}").exists?
        if zkconn.get("/clocker-#{lock_id}") == chef_node
          zkconn.delete("/clocker-#{lock_id}")
        end
      else
        return false
      end
    end

    # force the release lock
    def flockoff(lock_id)
      if zkconn.stat("/clocker-#{lock_id}").exists?
        zkconn.delete("/clocker-#{lock_id}")
      else
        return false
      end
    end

    # get lock info
    def glock(lock_id)
      unless zkconn.stat("/clocker-#{lock_id}")
        zkconn.get("/clocker-#{lock_id}")
      end
    end

    def close
      zkconn.close!
    end
  end

  class Lock
    def self.exists?(zk_host, lock_id, chef_node)
      Zk.new(zk_host).clock?(lock_id, chef_node)
    end

    def self.clockon(zk_host, lock_id, chef_node)
      unless Zk.new(zk_host).clock?(lock_id, chef_node)
        ret = Zk.new(zk_host).clockon(lock_id, chef_node)
      else
        ret = false
      end
      return ret
    end

    def self.clockoff(zk_host, lock_id, chef_node)
      unless Zk.new(zk_host).clockoff(lock_id, chef_node)
        owner = Zk.new(zk_host).glock(lock_id)
        Chef::Log.info("Unable to remove: #{lock_id}, owned by: #{owner}")
        return false
      end
    end

    # force a lock removal
    def self.flockoff(zk_host, lock_id)
      unless Zk.new(zk_host).flockoff(lock_id)
        Chef::Log.fatal("Unable to force removal of: #{lock_id}!")
      end
    end
  end
end
