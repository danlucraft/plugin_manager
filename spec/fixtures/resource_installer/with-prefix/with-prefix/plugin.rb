
Plugin.define do
  name         "With prefix"
  version      "1.0"
  object       "App::WithPrefix"
  file         "with-prefix"
  
  install "http://www.google.co.uk", "/index.html" => "google.html"
end