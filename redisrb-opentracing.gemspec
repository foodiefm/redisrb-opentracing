
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "redisrb/opentracing/version"

Gem::Specification.new do |spec|
  spec.name          = "redisrb-opentracing"
  spec.version       = [Redisrb::OpenTracing::VERSION, 'pre'].join('.')
  spec.authors       = ['larte']
  spec.email         = ['devops@foodie.fm']

  spec.summary       = 'OpenTracing instrumentation for redis-rb'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/foodiefm/redisrb-opentracing'
  spec.license       = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/foodiefm/redisrb-opentracing/issues',
    'homepage_uri'    => 'https://github.com/foodiefm/redisrb-opentracing',
    'source_code_uri' => 'https://github.com/foodiefm/redisrb-opentracing',
  }

  spec.files         = %w(README.md Rakefile) + Dir.glob("{doc,lib}/**/*")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']


  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'opentracing_test_tracer', '~> 0.1'
  spec.add_development_dependency 'appraisal', '~> 2'
  spec.add_development_dependency 'rubocop', '~> 0.71.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.33.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
  spec.add_development_dependency 'coveralls'

  spec.add_dependency 'redis', '>= 3.2', '< 5'
  spec.add_dependency 'opentracing', '~> 0.4'
end
