require "bundler/setup"
require 'coveralls'
Coveralls.wear!
require "redisrb/opentracing"
require 'redis'
require 'opentracing_test_tracer'
require 'database_cleaner'


def test_redis
  ::Redis.new
end


RSpec::Expectations.configuration.on_potential_false_positives = :nothing
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner[:redis,
                    { connection: test_redis }].strategy = :truncation
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
