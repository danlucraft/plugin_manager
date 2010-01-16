
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
    
  end
end