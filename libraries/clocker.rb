class Chef
  class Resource::Clocker < Resource
    def initialize(name, run_context = nil)
      super

      @resource_name = :clocker_lock
      @provider = Provider::Clocker
      @action = :clockon
      @allowed_actions.push(:clockon, :clockoff)
    end

    def zookeeper(arg = nil)
      set_or_return(:zookeeper, arg, kind_of: String)
    end

    def lockwait(arg = nil)
      set_or_return(:lockwait, arg, kind_of: [ Integer, FalseClass, TrueClass ])
    end
  end

  class Provider::Clocker < Provider
    def load_current_resource
      require 'zk'
      @current_resource = Chef::Resource::Clocker.new(@new_resource_name)
      @current_resource.name(@new_resource.name)
      @current_resource.zookeeper(@new_resource.zookeeper)
      @current_resource.lockwait(@new_resource.lockwait)
      @current_resource
      # Setup a zk connection and a locker for later use
      @zkconn = ZK.new(@new_resource.zookeeper)
      @aclocker = @zkconn.locker(@new_resource.name)
    end

    def cleanup_after_converge
      @zkconn.close
    end

    def action_clockon
      @aclocker.lock({ :wait => @new_resource.lockwait })
      puts "sleep......................"
      puts "sleep......................"
      puts "sleep......................"
      sleep(10)
    end

    def action_clockoff
      @aclocker.unlock
    end
  end
end
