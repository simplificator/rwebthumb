Gem::Specification.new do |s|
  s.name = %q{rwebthumb}
  s.version = "0.1.0"
  s.date = %q{2008-07-11}
  s.authors = ["Simplificator GmbH"]
  s.email = %q{info@simplificator.com}
  s.summary = %q{rwebthumb provides a ruby interface for the webthumb.bluga.net}
  s.homepage = %q{http://labs.simplificator.com/}
  s.description = %q{rwebthumb provides a ruby interface for the webthumb.bluga.net}
  s.files = ["lib/rwebthumb.rb", "lib/rwebthumb/base.rb", "lib/rwebthumb/job.rb", "lib/rwebthumb/webthumb.rb", "test/base_test.rb", "test/helper.rb", "test/job_test.rb", "test/webthumb_test.rb", "README", "init.rb"]
  # can not use this on github...
  #s.files = Dir['lib/**/*.rb'] + Dir['test/**/*']
  #s.files << ['README', 'init.rb']
  #s.files.reject! { |fn| fn.include? "nbproject" }
end