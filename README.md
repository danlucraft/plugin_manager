
Plugin Manager
==============

This is a plugin loader for Ruby. Features:

  * dependencies
  * versioning
  * multiple plugin sources
  * safe against plugins with broken code
  * plugin code reloading
  
It is not tied to Rubygems or Rails. A plugin is any directory with a plugin.rb file
inside that looks like this:
    
    Plugin.define do
      name         "Extras"
      version      "1.0"
      
      # the file to load to load the plugin. It is expected to be an .rb
      # file relative to this definition
      file         "extras"
      
      # this is an object that is defined by the plugin code
      object       "App::Extras"
      
      # Dependencies of the plugin
      dependencies "core", ">=1.0",
                   "fonts", ">=0.5, <1.9",
                   "debug", ">0, !=0.95, < 2"
    end

See the spec/fixtures/example/ directory for an example of a set of plugins.

This
directory of plugins can be loaded with:

    manager = PluginManager.new
    manager.add_plugin_source("spec/fixtures/example")
    manager.load

The code in the appropriate plugins will be loaded and you will then have available:
    
    # plugins that were loaded successfully
    manager.loaded_plugins
    
    # plugins that could not be loaded because of unmet dependencies, 
    # or because a more recent version was available.
    manager.unloaded_plugins
    
    # plugin.rb files that could not be read
    manager.unreadable_definitions
    
    # plugins that raised exceptions while being loaded
    manager.plugins_with_errors

NB. There is a BIG difference between this and say, Rubygems, in that plugin_manager will ONLY EVER
LOAD THE MOST RECENT VERSION OF A PLUGIN. Older versions essentially DON'T EXIST from the point of view
of the plugin_manager.

License
=======

MIT