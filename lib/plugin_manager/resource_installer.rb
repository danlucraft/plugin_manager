
require 'net/http'

class PluginManager
  class ResourceInstaller
    S3_BAD_MESSAGE = "got Access Denied from S3."
    BAD_SOURCE_MESSAGE = "Dont recognize source type. Currently only HTTP resources are supported."
    
    def initialize(manager)
      @manager = manager
    end
    
    def install_to(dir)
      @manager.loaded_plugins.each do |plugin|
        dir_path = resource_dir(dir, plugin)
        plugin.resources.each do |source, filename|
          FileUtils.mkdir(dir_path) unless File.exist?(dir_path)
          file_path = File.join(dir_path, filename)
          next if File.exist?(file_path)
          
          if source =~ /^http/
            File.open(file_path, "wb") do |f|
              f.print http.get(URI.parse(source))
            end
            
            if File.open(file_path).read(200) =~ /Access Denied/
              @manager.output.puts "Error downloading #{source}, #{S3_BAD_MESSAGE}"
              FileUtils.rm_rf(file_path)
              exit
            end
          else
            @manager.output.puts "Error downloading #{source}, #{BAD_SOURCE_MESSAGE}"
            exit
          end
        end
      end
    end
    
    def resource_dir(dir, plugin)
      dir_name = File.basename(File.dirname(plugin.definition_file))
      File.join(dir, dir_name)
    end
    
    def http=(val)
      @http = val
    end
    
    private
    
    def http
      @http ||= begin
        if ENV['http_proxy']
          proxy = URI.parse(ENV['http_proxy'])
          Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password)
        else
          Net::HTTP
        end
      end
    end
  end
end