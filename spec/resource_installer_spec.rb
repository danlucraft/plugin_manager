
require 'spec_helper'

describe PluginManager::ResourceInstaller do
  def tmp_dir
    File.dirname(__FILE__) + "/tmp"
  end
  
  class FakeHttp
    attr_reader :get_count
    
    def initialize
      @get_count = 0
    end
    
    def get(*_)
      @get_count += 1
      "Fake File"
    end
  end
  
  before do
    FileUtils.mkdir(tmp_dir)
    @output = StringIO.new
    @manager = PluginManager.new(@output)
  end
  
  after do
    FileUtils.rm_rf(tmp_dir)
  end
  
  context "valid resource" do
    before do
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures resource_installer example)))
      @manager.load
    end
    
    it "should download defined resources to a predefined location" do
      @manager.install_to(tmp_dir)
      
      Dir[tmp_dir + "/*"].map {|dn| File.basename(dn) }.should be_include("core")
      Dir[tmp_dir + "/core/*"].map {|fn| File.basename(fn) }.should be_include("google.html")
    end
    
    it "should only download the same resource once" do
      @fake_http = FakeHttp.new
      @manager.resource_installer.http = @fake_http

      @manager.install_to(tmp_dir)
      @manager.install_to(tmp_dir)
      
      @fake_http.get_count.should == 1
    end
    
    it "should let you get resource file names for a plugin" do
      @manager.install_to(tmp_dir)
      @manager.resource_dir(@manager.loaded_plugins.first).should == tmp_dir + "/core"
    end
  end

  context "bad s3 file" do
    before do
      @manager.add_plugin_source(File.join(File.dirname(__FILE__), %w(fixtures resource_installer s3-denied)))
      @manager.load
    end
    
    it "should quit the installer" do
      lambda {
        @manager.install_to(tmp_dir)
      }.should raise_error(SystemExit)
    end
    
    it "should report if the file downloaded was an S3 access denied file" do
      begin
        @manager.install_to(tmp_dir)
      rescue SystemExit
      end
        
      Dir[tmp_dir + "/*"].map {|dn| File.basename(dn) }.should be_include("core")
      Dir[tmp_dir + "/core/*"].map {|dn| File.basename(dn) }.should_not be_include("bad_file.html")
      @output.rewind
      @output.read.should be_include(PluginManager::ResourceInstaller::S3_BAD_MESSAGE)
    end
  end
end



