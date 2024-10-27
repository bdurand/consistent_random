# frozen_string_literal: true

class ConsistentRandom
  # Sidekiq server middleware that wraps job execution with consistent random scope
  # so that you can generate consistent random values within a job.
  class SidekiqMiddleware
    if defined?(Sidekiq::ServerMiddleware)
      include Sidekiq::ServerMiddleware
    end

    class << self
      def install
        Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.prepend ConsistentRandom::SidekiqMiddleware
          end

          config.client_middleware do |chain|
            chain.add ConsistentRandom::SidekiqClientMiddleware
          end
        end

        Sidekiq.configure_client do |config|
          config.client_middleware do |chain|
            chain.add ConsistentRandom::SidekiqClientMiddleware
          end
        end
      end
    end

    def call(job_instance, job_payload, queue)
      ConsistentRandom.scope(job_payload["consistent_random_seed"]) do
        yield
      end
    end
  end
end
