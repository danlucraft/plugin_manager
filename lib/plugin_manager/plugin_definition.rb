
class PluginManager
  class PluginDefinition
    attr_accessor :name,
                  :version,
                  :object,
                  :file,
                  :dependencies,
                  :definition_file
                  
    def inspect
      "<Plugin #{name} #{version} depends:[#{(dependencies||[]).map{|dep| dep.join("")}.join(", ")}] #{required_files.length} files>"
    end
    
    def required_files
      @required_files ||= []
    end
    
    def load
      required_files.each {|file| $".delete(file) }
      new_files = log_requires do
        require File.expand_path(File.join(File.dirname(definition_file), file))
      end
      required_files.unshift(*new_files)
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