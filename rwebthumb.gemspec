Gem::Specification.new do |s|
  s.name = %q{rwebthumb}
  s.version = "0.0.1"
  s.date = %q{2008-07-10}
  s.authors = ["Simplificator GmbH"]
  s.email = %q{gems@simplificator.com}
  s.summary = %q{rwebthumb provides a ruby interface for the webthumb.bluga.net}
  s.homepage = %q{http://labs.simplificator.com/}
  s.description = %q{rwebthumb provides a ruby interface for the webthumb.bluga.net}
  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*']
  s.files << ['README', 'init.rb']
  s.files.reject! { |fn| fn.include? "nbproject" }
end