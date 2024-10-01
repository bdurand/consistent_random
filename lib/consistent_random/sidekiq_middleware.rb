# frozen_string_literal: true

class ConsistentRandom
  # Sidekiq server middleware that wraps job execution with consistent random scope
  # so that you can generate consistent random values within a job.
  class SidekiqMiddleware
    if defined?(Sidekiq::ServerMiddleware)
      include Sidekiq::ServerMiddleware
    end

    def call(job_instance, job_payload, queue)
      ConsistentRandom.scope do
        yield
      end
    end
  end
end
