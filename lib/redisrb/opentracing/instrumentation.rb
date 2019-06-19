require 'opentracing'

module Redisrb
  module OpenTracing
    module Instrumentation
      TAGS = {
        'db.type' => 'redis',
      }.freeze


      def call(command)
        tags = TAGS.dup
        tags['db.key'] = command[1].to_s if command[1]
        tags['db.instance'] = db

        scope = ::OpenTracing.start_active_span(['redis', command[0]].join('.'),
                                              tags: tags)
        super(command)
      rescue => e
        if scope
          scope.span.set_tag('error', true)
          scope.span.log_kv(key: 'error', value: e.message)
        end
        raise e
      ensure
        scope.close
      end

      def call_pipeline(pipeline)
        commands = pipeline.commands
        commands_str = commands.collect {|x| [x.first, x[1] || ''].join(' ') }.join(',')
        tags = TAGS.dup
        tags['db.instance'] = db
        tags['db.pipeline_operations'] = logged_pipeline_commands(commands).join(', ')

        scope = ::OpenTracing.start_active_span('redis.pipelined',
                                                tags: tags)
        super(pipeline)
      rescue => e
        if scope
          scope.span.set_tag('error', true)
          scope.span.log_kv(key: 'error', value: e.message)
        end
        raise e
      ensure
        scope.close
      end

      def logged_pipeline_commands(commands)
        return commands.collect do |name, *args|
          key = args.first
          key_str = case
                    when key.nil?
                      nil
                    when key.respond_to?(:inspect) then key.inspect
                    when key.respond_to(:to_s) then key.to_s
                    else
                      nil
                    end
          [name, key_str].compact.join(' ')
        end
      end
    end
  end
end
