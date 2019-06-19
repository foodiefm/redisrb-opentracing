require "redisrb/opentracing/version"
require "redisrb/opentracing/instrumentation"

module Redisrb
  module OpenTracing
    def self.instrument
      ::Redis::Client.send(:prepend, Instrumentation)
      self
    end
  end
end
