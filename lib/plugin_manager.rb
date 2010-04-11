
$:.unshift(File.dirname(__FILE__))

require 'plugin_manager/plugin'
require 'plugin_manager/plugin_definition'
require 'plugin_manager/definition_builder'

class PluginManager
  attr_reader :unreadable_definitions, :plugins_with_errors, :loaded_plugins, :unloaded_plugins

  def initialize
    @unloaded_plugins = []
    @loaded_plugins = []
    @unreadable_definitions = []
    @plugins_with_errors = []
  end

  def plugins
    @unloaded_plugins + @loaded_plugins
  end
  
  def plugin_objects
    @loaded_plugins.map {|definition| definition.object}
  end
  
  def objects_implementing(method_name)
    plugin_objects.select {|obj| obj.respond_to?(method_name) }
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
        rescue Object => e
          puts "Unreadable plugin definition: #{file}"
          puts "  " + e.message
          puts e.backtrace.map {|l| "  " + l }
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
          puts "[PluginManager] loading #{plugin.name}" if ENV["PLUGIN_DEBUG"]
          plugin.load
          @loaded_plugins << plugin
        rescue Object => e
          puts "Error loading plugin: #{plugin.inspect}"
          puts "  " + e.message
          puts e.backtrace.map {|l| "  " + l }
          @plugins_with_errors << plugin
        end
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
        req_name, req_ver = *dep
        @loaded_plugins.detect do |d1| 
          d1.name == req_name and 
            PluginManager.compare_version(req_ver, d1.version)
        end
      end
    end
  end
  
  def self.compare_version(required, got)
    got = got.gsub(/(\.0)+$/, "")
    required.split(",").all? do |req|
      req = req.strip
      req = req.gsub(/(\.0)+$/, "")
      if md = req.match(/^(=|>|>=|<|<=|!=)?([\d\.]*)$/)
        case md[1]
        when ">"
          got > md[2]
        when ">="
          got >= md[2]
        when "<"
          got < md[2]
        when "<="
          got <= md[2]
        when "="
          md[2] == got
        when "!="
          md[2] != got
        end
      else
        puts "don't recognize version string: #{required.inspect}"
      end
    end
  end
end


