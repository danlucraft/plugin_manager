
Plugin.define do
  name         "Debug"
  version      "1.0"
  object       "App::Debug"
  file          File.join(File.dirname(__FILE__), %w(debug))
  dependencies "Extras", ">=1.0"
end