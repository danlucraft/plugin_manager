
class PluginManager
  class PluginDefinition
    attr_accessor :name,
                  :version,
                  :object,
                  :file,
                  :dependencies,
                  :definition_file
                  
    def inspect
      "<Plugin #{name} #{version} depends:[#{(dependencies||[]).map{|dep| dep.join("")}.join(", ")}]>"
    end
  end
end