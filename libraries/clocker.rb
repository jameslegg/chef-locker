class Clocker
  # Abstraction of ZK gem connection and locking to allow reuse of connections
  # betwen chef resources
  class ZKs
    def initialize
      # hash of zookeeper locks we use one connection per lock id
      # (ClassVars are needed to share between instances and chef resources)
      @@zkls = {} # rubocop:disable Style/ClassVars
    end

    # Create or retrieve a locker as appropriate
    # rubocop:disable Style/MethodLength
    def locker(lock, zookeeper = nil)
      require 'zk'
      if @@zkls.include?(lock)
        Chef::Log.debug("Returning locker for #{lock}")
        @@zkls[lock]
      elsif zookeeper
        Chef::Log.debug("Creating zookeeper connection for #{lock}")
        zkc = ZK.new(zookeeper)
        @@zkls[lock] = ZK.new(zookeeper)
        @@zkls[lock] = zkc.locker(lock)
      else
        # Lock neither found nor created
        Chef::Log.debug("No lock found for #{lock}")
        false
      end
    end

    def disco(lock)
      Chef::Log.debug("Disconecting #{lock}'s zookeeper connection")
      @@zkls[lock].close if @@zkls.include?(lock)
    end
  end
end

class Chef
  # Clocker Class provides a point to call the held? method from within chef
  # recipes
  class Recipe::Clocker
    # Check with the zookeeper server if the lock is still being held
    # We need the run_context passed to us so we can look inside the resource
    # collection for our clocker resource.
    def self.held?(lock_id, run_context)
      # We must dig the clocker resource out of the resource collection.
      begin
        cl = run_context.resource_collection.find(clocker: lock_id)
      rescue Chef::Exceptions::ResourceNotFound
        # That clocker resource dosn't exist in the resource collection
        Chef::Log.warn("clocker[#{lock_id}] not found!")
        return false
      end
      # Use the existing ZK::Locker to establish if the lock still exists
      zkconn = cl.zkconn
      aclocker = zkconn.locker(lock_id)
      if aclocker
        aclocker.assert
      else
        aclocker
      end
    end
  end

  # clocker resource for taking and releasing zookeeper locks
  class Resource::Clocker < Resource
    def initialize(name, run_context = nil)
      super

      @provider = Provider::Clocker
      @action = :clockon
      @allowed_actions.push(:clockon, :clockoff)
      # Clocker::ZKs with the same lockid are shared between diffrent Resources
      # this allows them to share a single connection to zookeeper
      @zkconn = ::Clocker::ZKs.new
    end

    def zookeeper(arg = nil)
      set_or_return(:zookeeper, arg, kind_of: String, required: true)
    end

    def lockid(arg = nil)
      set_or_return(:lockid, arg, kind_of: String, required: true)
    end

    def lockwait(arg = nil)
      set_or_return(:lockwait, arg, kind_of: [Integer, FalseClass, TrueClass])
    end

    def zkconn(arg = nil)
      set_or_return(:zkconn, arg, kind_of: Object)
    end
  end

  # provider for the clockon and clockoff actions of the clocker resource
  class Provider::Clocker < Provider
    def load_current_resource
      @name = new_resource.name
      @lockid = new_resource.lockid
      @zookeeper = new_resource.zookeeper
      @lockwait = new_resource.lockwait
      @zkconn = new_resource.zkconn
      @aclocker = @zkconn.locker(@lockid,  @zookeeper)
    end

    def action_clockon
      Chef::Log.info("Taking lock: #{@lockid}")
      begin
        @aclocker.lock({ :wait => @lockwait, :blocking => true})
      rescue ZK::Exceptions::LockWaitTimeoutError
        # We don't get the lock, but we don't fail the chef run
        Chef::Log.warn("Unable to obtain #{@lockid}")
        return false
      end
    end

    def action_clockoff
      Chef::Log.info("Releasing lock: #{@lockid}")
      @aclocker.unlock
      @zkconn.disco(@zookeeper)
    end
  end
end
