
class PluginManager
  class DefinitionBuilder
    def initialize(&block)
      @block = block
      @definition = PluginDefinition.new
    end
    
    def build
      instance_eval(&@block)
      @definition
    end
    
    def name(value)
      @definition.name = value
    end
    
    def version(value)
      @definition.version = value
    end
    
    def object(value)
      @definition.object_string = value
    end
    
    def file(*values)
      @definition.file = values
    end
    
    def install(arg1, arg2=nil)
      if arg2
        prefix = arg1
        hash   = Hash[arg2.map {|k, v| [prefix + k, v]}]
      else
        hash = arg1
      end
      @definition.resources.merge!(hash)
    end
    
    def dependencies(*deps)
      @definition.dependencies ||= []
      deps.each_slice(2) do |name, ver|
        @definition.dependencies << [name, ver]
      end
    end
  end
end