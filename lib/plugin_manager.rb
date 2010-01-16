
$:.unshift(File.dirname(__FILE__))

require 'plugin_manager/plugin'
require 'plugin_manager/plugin_definition'
require 'plugin_manager/definition_builder'

class PluginManager
  def initialize
    @plugin_sources = []
    @loaded_plugins = []
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
    @plugin_definitions ||= begin
      plugin_definition_files.map do |file|
        begin
          definition = instance_eval(File.read(file))
          definition.containing_directory = File.dirname(file)
          definition
        rescue Object
        end
      end.compact.sort_by {|p| p.name.downcase }
    end
  end
  
  def load
    all_plugins = plugin_definitions
    while all_plugins.any?
      next_to_load = all_plugins.detect do |d|
        (d.dependencies||[]).all? do |dep|
          @loaded_plugins.detect {|d1| d1.name == dep.first }
        end
      end
      begin
        require File.join(next_to_load.containing_directory, next_to_load.file)
      rescue Object
      end
      @loaded_plugins << next_to_load
      all_plugins.delete(next_to_load)
    end
  end
end