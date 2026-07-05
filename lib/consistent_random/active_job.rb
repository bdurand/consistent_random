# frozen_string_literal: true

class ConsistentRandom
  module ActiveJob
    # @return [String, nil] the seed deserialized from the job data
    # @api private
    attr_reader :consistent_random_seed

    def self.included(base)
      base.around_perform :perform_with_consistent_random_scope

      base.class_attribute :inherit_consistent_random_scope, instance_writer: false
    end

    def serialize
      job_data = super
      if inherit_consistent_random_scope != false
        seed = ConsistentRandom.current_seed
        job_data["consistent_random_seed"] = seed unless seed.nil?
      end
      job_data
    end

    def deserialize(job_data)
      super
      @consistent_random_seed = job_data["consistent_random_seed"]
    end

    private

    def perform_with_consistent_random_scope(&block)
      seed = consistent_random_seed unless inherit_consistent_random_scope == false
      ConsistentRandom.scope(seed, &block)
    end
  end
end
