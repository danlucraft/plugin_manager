
Plugin.define do
  name         "Core"
  version      "1.0"
  object       "App::Core2"
  file         "core"
  
  install "http://redcar.s3.amazonaws.com/asdf.adf" => "bad_file.html"
end