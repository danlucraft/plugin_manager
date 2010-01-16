
$:.unshift(File.dirname(__FILE__))

require 'plugin_manager/plugin'
require 'plugin_manager/plugin_definition'
require 'plugin_manager/definition_builder'

class PluginManager
  def initialize
    @plugin_sources = []
  end

  def add_plugin_source(directory)
    @plugin_sources << File.expand_path(directory)
  end
  
  def plugin_definition_files
    @plugin_sources.map do |source|
      Dir[File.join(source, "*", "plugin.rb")]
    end.flatten
  end
  
  def plugin_definitions
    plugin_definition_files.map do |file|
      instance_eval(File.read(file))
    end
  end
end