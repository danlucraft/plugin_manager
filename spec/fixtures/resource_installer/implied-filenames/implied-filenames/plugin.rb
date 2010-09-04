
Plugin.define do
  name         "Implied Filenames Test"
  version      "1.0"
  object       "App::ImpliedFilenames"
  file         "implied-filenames"
  
  install "http://www.google.ca", ["/foo", "/bar"]
  install "http://www.google.ca/baz"
end