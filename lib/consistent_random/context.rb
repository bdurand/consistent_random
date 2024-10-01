# frozen_string_literal: true

class ConsistentRandom
  class Context
    # @api private
    attr_reader :seeds

    # @param existing_context [Context, nil] Existing context to copy generators from
    def initialize(existing_context = nil)
      @seeds = (existing_context ? existing_context.seeds.dup : {})
    end

    # Return a random number generator for the given name and seed
    #
    # @param name [String] Name of the generator
    # @return [Random] Random number generator
    def seed(name)
      @seeds[name] ||= Random.new_seed
    end
  end
end
