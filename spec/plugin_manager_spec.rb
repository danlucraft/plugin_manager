
require File.join(File.dirname(__FILE__), "spec_helper")

describe PluginManager do
  describe "loading plugin definitions" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures example)))
    end
    
    it "should find plugin files inside the source" do
      @manager.plugin_definition_files.map do |f| 
        f[/example\/(.*)\/plugin.rb/, 1]
      end.sort.should == %w(core debug extras)
    end
    
    it "should load the plugin definitions" do
      @manager.plugin_definitions.length.should == 3
      @manager.plugin_definitions.map {|d| d.name }.should == %w(Core Debug Extras)
    end
  end
  
  describe "loading plugin definitions with syntax errors in them" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures error_in_definition)))
    end
    
    it "should not die when loading the definition" do
      @manager.plugin_definitions
    end
  end
  
  describe "loading plugins" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures example)))
      @manager.load
    end
    
    it "should load the plugins respecting dependencies" do
      App.plugins.should == [:core, :extras, :debug]
    end
  end
  
  describe "loading plugins with errors in them" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures error_in_plugin)))
    end
    
    it "should not die when loading plugins" do
      @manager.load
    end
  end
end
