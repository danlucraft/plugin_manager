
require File.join(File.dirname(__FILE__), "spec_helper")

describe PluginManager do
  
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