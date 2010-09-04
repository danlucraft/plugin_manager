
Plugin.define do
  name         "Multiple installs"
  version      "1.0"
  object       "App::MultipleInstalls"
  file         "multiple-installs"
  
  install "http://www.google.ca", "/index.html" => "google-ca.html"
  install "http://www.google.co.uk" => "google-uk.html"
end