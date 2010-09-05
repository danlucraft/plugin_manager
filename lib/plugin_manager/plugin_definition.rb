
class PluginManager
  class PluginDefinition
    attr_accessor :name,
                  :version,
                  :object_string,
                  :file,
                  :definition_file,
                  :resources
                  
    def inspect1              
      "<Plugin #{name} #{version} depends:#{dependencies.inspect} #{required_files.length} files>"
    end
    
    def inspect
      inspect1
    end
    
    def resources
      @resources ||= {}
    end
    
    def required_files
      @required_files ||= []
    end
    
    def dependencies
      @dependencies ||= []
    end
    
    def load_time
      @load_time
    end
    
    def load
      s = Time.now
      required_files.each {|file| $".delete(file) }
      load_file = File.expand_path(File.join(File.dirname(definition_file), file))
      $:.unshift(File.dirname(load_file))
      new_files = log_requires do
        require load_file
      end
      required_files.unshift(*new_files)
      if object.respond_to?(:loaded)
        object.loaded
      end
      @load_time = Time.now - s
    end
    
    def object
      eval(object_string)
    end
    
    private
    
    def log_requires
      before = $".dup 
      yield
      after = $".dup
      result = after - before
      result
    end
  end
end