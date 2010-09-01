
module App
  def self.plugins
    @plugins ||= []
  end
  
  class << self
    attr_accessor :times_loaded
  end
  
  if self.times_loaded 
    self.times_loaded += 1
  else
    self.times_loaded = 1
  end
  
  class Core
    App.plugins << :core
  end
end