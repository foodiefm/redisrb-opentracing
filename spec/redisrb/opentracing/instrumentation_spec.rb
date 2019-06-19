require 'spec_helper'

RSpec.describe Redisrb::OpenTracing::Instrumentation do
  let(:redis) { test_redis }
  let(:tracer) { OpenTracingTestTracer.build }

  before do
    OpenTracing.global_tracer = tracer
    ::Redis::Client.send(:prepend, described_class)
  end


  RSpec.shared_examples 'correct span' do
    it 'records span' do
      expect(spans.count).to eq(1)
    end

    it 'tags type' do
      span = spans.last
      expect(span.tags['db.type']).to eql('redis')
    end

    it 'tags db.instance' do
      span = spans.last
      expect(span.tags['db.instance']).to eql(0)
    end

    it 'adds operation name' do
      expect(spans.last.operation_name).to eql(name)
    end
  end


  describe 'tracing .set' do
    before do
      redis.set('foo', 1)
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
      let(:name) { 'redis.set' }
    end
  end

  describe 'tracing .get' do
    before do
      redis.get('foo')
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
      let(:name) { 'redis.get' }
    end
  end

  describe 'tracing multi' do
    before do
      redis.multi do
        redis.set 'foo', 1
        redis.set 'bar', 2
      end
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
      let(:name) { 'redis.pipelined' }
    end
  end


  describe 'tracing pipelined operations' do
    before do
      redis.pipelined do
        redis.set 'foo', 1
        redis.incr 'baz'
        redis.flushall
      end
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
      let(:name) { 'redis.pipelined' }
    end

    it 'has pipeline commands in tags' do
      span = tracer.spans.last
      expect(span.tags['db.pipeline_operations'])
        .to eql('set "foo", incr "baz", flushall')
    end
  end

  describe 'on error states' do
    before do
      expect { redis.foo('1') }.to raise_error
    end

    it_behaves_like 'correct span' do
      let(:spans) { tracer.spans }
      let(:name) { 'redis.foo' }
    end

    it 'span has error tag' do
      span = tracer.spans.last
      expect(span.tags['error']).to be_truthy
    end

    it 'logs error' do
      span = tracer.spans.last
      expect(span.logs).to include(hash_including({key: 'error'}))
    end
  end
end
