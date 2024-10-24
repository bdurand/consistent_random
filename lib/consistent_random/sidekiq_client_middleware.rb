# frozen_string_literal: true

class ConsistentRandom
  # Sidekiq client middleware that adds the current seeds to the job options. These
  # seeds will be deserialized and used when the job is run on the server so that
  # the client and server can share consistent random values.
  class SidekiqClientMiddleware
    if defined?(Sidekiq::ClientMiddleware)
      include Sidekiq::ClientMiddleware
    end

    def call(job_class_or_string, job, queue, redis_pool)
      unless job["consistent_random"] == false
        seed = ConsistentRandom.current_seed
        job["consistent_random_seed"] = seed unless seed.nil?
      end
      yield
    end
  end
end
