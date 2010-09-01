
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
    
    def install(resources)
      @definition.resources = resources
    end
    
    def dependencies(*deps)
      @definition.dependencies ||= []
      deps.each_slice(2) do |name, ver|
        @definition.dependencies << [name, ver]
      end
    end
  end
end