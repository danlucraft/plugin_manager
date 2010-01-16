
class PluginManager
  class Plugin
    def self.define(&block)
      builder = DefinitionBuilder.new(&block)
      builder.build
    end
  end
end