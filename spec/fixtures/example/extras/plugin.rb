
Plugin.define do
  name         "Extras"
  version      "1.0"
  object       "App::Extras"
  file          File.join(File.dirname(__FILE__), %w(extras))
  dependencies "Core", ">=1.0"
end