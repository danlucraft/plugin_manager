
$:.unshift(File.dirname(__FILE__))

require 'plugin_manager/plugin'
require 'plugin_manager/plugin_definition'
require 'plugin_manager/definition_builder'

class PluginManager
  def initialize
    @unloaded_plugins = []
    @loaded_plugins = []
  end

  def plugins
    @unloaded_plugins + @loaded_plugins
  end

  def add_plugin_source(directory)
    definition_files = Dir[File.join(File.expand_path(directory), "*", "plugin.rb")]
    definition_files.reject! {|f| plugins.any? {|pl| pl.definition_file == File.expand_path(f) } }
    new_definitions = 
      definition_files.map do |file|
        begin
          definition = instance_eval(File.read(file))
          definition.definition_file = File.expand_path(file)
          definition
        rescue Object
        end
      end.compact.sort_by {|p| p.name.downcase }
    @unloaded_plugins += new_definitions
  end
  
  def load
    while @unloaded_plugins.any?
      next_to_load = @unloaded_plugins.detect do |d|
        (d.dependencies||[]).all? do |dep|
          @loaded_plugins.detect {|d1| d1.name == dep.first }
        end
      end
      begin
        require File.join(File.dirname(next_to_load.definition_file), next_to_load.file)
      rescue Object
      end
      @loaded_plugins << next_to_load
      @unloaded_plugins.delete(next_to_load)
    end
  end
end