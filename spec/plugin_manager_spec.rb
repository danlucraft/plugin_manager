
require File.join(File.dirname(__FILE__), "spec_helper")

describe PluginManager do
  before do
    @before_files = $".clone
    if defined?(App)
      App.times_loaded = 0
    end
  end
  
  after do
    added_files = $".clone - @before_files
    added_files.each do |file|
      $".delete(file)
    end
  end
  
  describe "loading plugin definitions" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures example)))
    end
    
    it "should find plugin files inside the source" do
      @manager.plugins.map do |f| 
        f.definition_file[/example\/(.*)\/plugin.rb/, 1]
      end.sort.should == %w(core debug extras)
    end
    
    it "should load the plugin definitions" do
      @manager.plugins.length.should == 3
      @manager.plugins.map {|d| d.name }.should == %w(Core Debug Extras)
    end
  end
  
  describe "loading plugin definitions with syntax errors in them" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures error_in_definition)))
    end
    
    it "should not die when loading the definition" do
      @manager.plugins.length.should == 0
    end
    
    it "should report it as an error" do
      @manager.unreadable_definitions.length.should == 1
      @manager.unreadable_definitions.first.should == 
        File.expand_path(File.join(File.dirname(__FILE__), %w(fixtures error_in_definition core plugin.rb)))
    end
  end
  
  describe "loading plugins" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures example)))
      @manager.load
    end
    
    it "should load the plugins in dependency order" do
      App.plugins.should == [:core, :extras, :debug]
    end
    
    it "should record the files that were loaded" do
      @manager.plugins.find {|pl| pl.name == "Core"}.required_files.length.should == 1
    end
    
    it "should record the time taken to load the plugin" do
      @manager.plugins.find {|pl| pl.name == "Core"}.load_time.should be_an_instance_of(Float)
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
    
    it "should report them as having errors" do
      @manager.load
      @manager.plugins_with_errors.length.should == 1
      @manager.plugins_with_errors.first.name.should == "Core"
    end
  end
  
  describe "loading plugins with unmet dependencies because the plugin is missing" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures unmet_dependencies1)))
    end
    
    it "should load the rest of the plugins ok" do
      @manager.load
      @manager.loaded_plugins.map {|pl| pl.name }.should == ["Core"]
    end
  end

  describe "loading plugins with unmet dependencies because the plugin is not recent enough" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures unmet_dependencies2)))
    end
    
    it "should load the rest of the plugins ok" do
      @manager.load
      @manager.loaded_plugins.map {|pl| pl.name }.should == ["Core"]
    end
  end
  
  describe "reloading plugins" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures example)))
      @manager.load
    end
    
    it "should actually reload the code" do
      @manager.loaded_plugins.find {|pl| pl.name == "Core"}.load
      App.times_loaded.should == 2
    end
  end
  
  describe "loading when there are multiple versions" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures two_versions1)))
      @manager.load
    end
    
    it "should only load one version" do
      @manager.loaded_plugins.length.should == 1
    end
    
    it "should load the most recent version" do
      @manager.loaded_plugins.first.version.should == "2.0"
    end
  end
  
  describe "loading when there are multiple versions and the most recent has unmet deps" do
    before do
      @manager = PluginManager.new
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures two_versions2)))
      @manager.load
    end
     
    it "should only load one version" do
      @manager.loaded_plugins.length.should == 1
    end
    
    it "should load the most recent version with met dependencies" do
      @manager.loaded_plugins.first.version.should == "1.0"
    end
  end
    
  describe "version comparison" do
    it "should return true if it is equal" do
      PluginManager.compare_version("=1.0", "1.0").should be_true
    end
    
    it "should return false if it is not equal" do
      PluginManager.compare_version("=2.0", "1.0").should be_false
    end
    
    it "should return true if it is bigger than" do
      PluginManager.compare_version(">1.0", "2.0").should be_true
    end
    
    it "should return false if it is bigger than and not valid" do
      PluginManager.compare_version(">1.0", "0.5").should be_false
    end
    
    it "should return true if it is bigger than or equal to" do
      PluginManager.compare_version(">=1.0", "2.0").should be_true
      PluginManager.compare_version(">=1.0", "1.0").should be_true
      PluginManager.compare_version(">=1.0", "0.5").should be_false
    end
    
    it "should match against multiple requirements" do
      PluginManager.compare_version(">=1.0, <3.0", "2.0").should be_true
      PluginManager.compare_version(">1.0, <=3.0", "5.0").should be_false
      PluginManager.compare_version(">1.0, <3.0", "0.5").should be_false
    end
    
    it "should match not equal requirements" do
      PluginManager.compare_version("!=1.0", "2.0").should be_true
      PluginManager.compare_version("!=1.0", "0.999").should be_true
      PluginManager.compare_version("!=1.0", "1.0").should be_false
    end
    
    it "should not care about trailing 0s" do
      PluginManager.compare_version("=1.0", "1.0.0").should be_true
      PluginManager.compare_version("!=1.0", "1.0.0").should be_false
      PluginManager.compare_version("=1.0.0", "1.0").should be_true
      PluginManager.compare_version("!=1.0.0", "1.0").should be_false
      PluginManager.compare_version("=2.0.1.0", "2.0.1.0.0.0").should be_true
    end
  end
end









