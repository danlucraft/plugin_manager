
Plugin.define do
  name         "Core"
  version      "1.0"
  object       "App::Core2"
  file         "core"
  
  install "http://www.google.com/index.html" => "google.html"
end