
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
    
    def install(*args)
      if args.length == 1
        if Hash === args.first
          hash = args.first
        else
          hash = { args.first => File.basename(args.first) }
        end
      elsif args.length == 2
        prefix = args.first
        if Hash === args[1]
          hash   = Hash[args[1].map {|k, v| [prefix + k, v]}]
        elsif Array === args[1]
          hash = Hash[args[1].map {|path| [prefix + path, File.basename(path) ] } ]
        end
      end
      @definition.resources.merge!(hash)
    end
    
    def dependencies(*deps)
      @definition.dependencies ||= []
      deps.each_slice(2) do |name, ver|
        @definition.dependencies << PluginManager::Dependency.new(PluginManager.current, name, ver)
      end
    end
  end
end