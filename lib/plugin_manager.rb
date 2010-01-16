
$:.unshift(File.dirname(__FILE__))

require 'plugin_manager/plugin'
require 'plugin_manager/plugin_definition'
require 'plugin_manager/definition_builder'

class PluginManager
  attr_reader :unreadable_definitions, :plugins_with_errors, :loaded_plugins

  def initialize
    @unloaded_plugins = []
    @loaded_plugins = []
    @unreadable_definitions = []
    @plugins_with_errors = []
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
          puts "Unreadable plugin definition: #{file}"
          @unreadable_definitions << file
          nil
        end
      end.compact.sort_by {|p| p.name.downcase }
    @unloaded_plugins += new_definitions
  end
  
  def load
    previous_length = @unloaded_plugins.length + 1
    while previous_length > @unloaded_plugins.length
      previous_length = @unloaded_plugins.length
      if plugin = next_to_load
        begin
          plugin.load
        rescue Object => e
          puts "Error loading plugin: #{plugin}"
          puts "  " + e.message
          puts e.backtrace.map {|l| "  " + l }
          @plugins_with_errors << plugin
        end
        @loaded_plugins << plugin
        @unloaded_plugins.delete(plugin)
      end
    end
  end
  
  private
  
  def next_to_load
    # this ordering ensures we try the most recent version of a plugin first
    remaining_plugins = @unloaded_plugins.sort_by {|pl| pl.version }.reverse
    
    remaining_plugins.detect do |d|
      next if @loaded_plugins.map {|pl| pl.name }.include?(d.name)
      (d.dependencies||[]).all? do |dep|
        @loaded_plugins.detect {|d1| d1.name == dep.first }
      end
    end
  end
end


