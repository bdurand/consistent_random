# frozen_string_literal: true

class ConsistentRandom
  module ActiveJob
    def self.included(base)
      attr_reader :consistent_random_seeds

      base.around_perform :peform_with_consistent_random_scope

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
      @consistent_random_seeds = job_data["consistent_random_seed"]
    end

    private

    def peform_with_consistent_random_scope(&block)
      seeds = consistent_random_seeds unless inherit_consistent_random_scope == false
      ConsistentRandom.scope(seeds, &block)
    end
  end
end
