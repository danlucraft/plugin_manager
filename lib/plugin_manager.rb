
$:.unshift(File.dirname(__FILE__))

require 'plugin_manager/plugin'
require 'plugin_manager/plugin_definition'
require 'plugin_manager/definition_builder'

class PluginManager
  attr_reader :unreadable_definitions, :plugins_with_errors, :loaded_plugins, :unloaded_plugins, :output

  class << self
    attr_accessor :current
  end
  
  def initialize(output = STDOUT)
    @plugins                = []
    @unloaded_plugins       = []
    @loaded_plugins         = []
    @unreadable_definitions = []
    @plugins_with_errors    = []
    @output = output
  end

  def on_load(&block)
    @load_observer = block
  end
  
  def plugins
    @plugins
  end
  
  def plugin_objects
    @loaded_plugins.map {|definition| definition.object}
  end
  
  def objects_implementing(method_name)
    plugin_objects.select {|obj| obj.respond_to?(method_name) }
  end

  class Dependency
    attr_reader :required_name
    attr_reader :required_version
    
    def initialize(plugin_manager, required_name, required_version)
      @plugin_manager = plugin_manager
      @required_name = required_name
      @required_version = required_version
    end
    
    def satisfied?
      if loaded_plugin = @plugin_manager.loaded_plugins.detect {|pl| pl.name == required_name }
        PluginManager.compare_version(required_version, loaded_plugin.version)
      end
    end
    
    def inspect
      "dep(#{required_name} #{required_version})"
    end
  end
  
  def add_plugin_source(directory)
    definition_files = Dir[File.join(File.expand_path(directory), "*", "plugin.rb")]
    definition_files.reject! {|f| plugins.any? {|pl| pl.definition_file == File.expand_path(f) } }
    definition_files.each do |file|
      begin
        PluginManager.current = self
        definition = instance_eval(File.read(file))
        PluginManager.current = nil
        definition.definition_file = File.expand_path(file)
        if already_with_that_name = @plugins.detect {|pl| pl.name == definition.name }
          if already_with_that_name.version.to_f < definition.version.to_f
            @unloaded_plugins.delete(already_with_that_name)
            @plugins.delete(already_with_that_name)
            @unloaded_plugins << definition
            @plugins << definition
          end
        else
          @unloaded_plugins << definition
          @plugins << definition
        end
      rescue Object => e
        @output.puts "Unreadable plugin definition: #{file}"
        @output.puts "  " + e.message
        @output.puts e.backtrace.map {|l| "  " + l }
        @unreadable_definitions << file
        nil
      end
    end
    
    @plugins = @plugins.sort_by {|pl| pl.name }
    @unloaded_plugins = @unloaded_plugins.sort_by {|pl| pl.name }
  end
  
  def load(*plugin_names)
    if plugin_names.empty?
      return load_maximal
    else
      target_dependencies = plugin_names.map do |n| 
        unless result = latest_version_by_name(n) 
          raise "can't find plugin named #{n}"
        end
        Dependency.new(self, n, ">0")
      end
    end
    remaining_to_load = expand_dependencies(target_dependencies)
    while remaining_to_load.length > 0
      previous_length = remaining_to_load.length
      if plugin = next_to_load(remaining_to_load)
        load_plugin(plugin)
        remaining_to_load = remaining_to_load.reject {|dep| dep.required_name == plugin.name }
      else
        puts "no plugin to load from #{remaining_to_load.inspect}"
        return
      end
      new_length = remaining_to_load.length
    end
  end
  
  def latest_version_by_name(name)
    @plugins.select {|pl| pl.name == name }.sort_by {|pl| pl.version }.last
  end
  
  def load_plugin(plugin)
    begin
      @output.puts "[PluginManager] loading #{plugin.name}" if ENV["PLUGIN_DEBUG"]
      plugin.load
      if @load_observer
        @load_observer.call(plugin)
      end
      @loaded_plugins << plugin
    rescue Object => e
      @output.puts "Error loading plugin: #{plugin.inspect}"
      @output.puts "  " + e.message
      @output.puts e.backtrace.map {|l| "  " + l }
      @plugins_with_errors << plugin
    end
    @unloaded_plugins.delete(plugin)
  end
  
  def load_maximal
    while ready_plugin = @unloaded_plugins.detect {|pl| pl.dependencies.all? {|dep| dep.satisfied? }}
      load_plugin(ready_plugin)
    end
    @load_observer = nil # After loading all possible plugins, remove the load observer
  end
  
  def expand_dependencies(dependency_array)
    previous_length = dependency_array.length
    new_dependency_array = dependency_array.map do |dep|
      if pl = latest_version_by_name(dep.required_name)
        [dep, pl.dependencies]
      else
        dep
      end
    end.flatten.uniq
    if new_dependency_array.length > previous_length
      expand_dependencies(new_dependency_array)
    else
      new_dependency_array
    end
  end

  def next_to_load(dependency_array)
    hash = Hash.new {|h,k| h[k] = []}
    dependency_array.each {|dep| hash[dep.required_name] << dep.required_version}
    hash.each do |name, version_requirements|
      if candidate_for_loading = unloaded_plugins.detect {|pl| pl.name == name}
        all_requirements_met = version_requirements.all? do |version_requirement|
          PluginManager.compare_version(version_requirement, candidate_for_loading.version)
        end
        all_candidate_deps_met = candidate_for_loading.dependencies.all? {|dep| dep.satisfied?}
        return candidate_for_loading if all_requirements_met and all_candidate_deps_met
      end
    end
    nil
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
        @output.puts "don't recognize version string: #{required.inspect}"
      end
    end
  end
end


