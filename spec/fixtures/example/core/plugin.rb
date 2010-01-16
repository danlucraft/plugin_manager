
Plugin.define do
  name         "Core"
  version      "1.0"
  object       "App::Core"
  file          File.join(File.dirname(__FILE__), %w(core))
  dependencies "redcar", ">=1.0"
end