require 'spec_helper'

RSpec.describe Redisrb::OpenTracing do
  it 'has a version number' do
    expect(Redisrb::OpenTracing::VERSION).not_to be nil
  end

  context 'when instrumentation is applied' do
    let(:tracer) { OpenTracingTestTracer.build }
    let(:redis) { test_redis }

    before do
      OpenTracing.global_tracer = tracer
      described_class.instrument
      redis.set('foo', 1)
    end

    it 'records traces' do
      expect(tracer.spans.count).to eql(1)
    end
  end
end
