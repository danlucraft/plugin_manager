
module App
  def self.plugins
    @plugins ||= []
  end
  
  class Core
    App.plugins << :core
  end
end