
class PluginManager
  class PluginDefinition
    attr_accessor :name,
                  :version,
                  :object,
                  :file,
                  :dependencies,
                  :containing_directory
  end
end