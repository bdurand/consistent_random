# frozen_string_literal: true

require_relative "consistent_random/context"
require_relative "consistent_random/rack_middleware"
require_relative "consistent_random/sidekiq_middleware"

class ConsistentRandom
  class << self
    # Define a scope where consistent random values will be generated.
    #
    # @yield block of code to execute within the scope
    # @return the result of the block
    def scope
      existing_context = Thread.current[:consistent_random_context]
      begin
        context = Context.new(existing_context)
        Thread.current[:consistent_random_context] = context
        yield
      ensure
        Thread.current[:consistent_random_context] = existing_context
      end
    end
  end

  # @param name [Object] a name used to identifuy a consistent random value
  def initialize(name)
    @name = name
  end

  # Generate a random float. This method works the same as Kernel#rand.
  #
  # @param max [Integer, Range] the maximum value of the random float or a range indicating
  #  the minimum and maximum values.
  # @return [Numeric] a random number. If the max argument is a range, then the result will be
  #   a number in that range. If max is an number, then it will be an integer between 0 and that
  #   value. Otherwise, it will be a float between 0 and 1.
  def rand(max = nil)
    random.rand(max || 1.0)
  end

  # Generate a random integer. This method works the same as Random#bytes.
  #
  # @param size [Integer] the number of bytes to generate.
  # @return [String] a string of random bytes.
  def bytes(size)
    random.bytes(size)
  end

  # Generate a random number generator for the given name. The generator will always
  # have the same seed within a scope.
  #
  # @return [Random] a random number generator
  def random
    Random.new(current_context.seed(@name))
  end

  # @return [Boolean] true if the other object is a ConsistentRandom that returns
  #   the same random number generator. If called outside of a scope, then it will
  #   always return false.
  def ==(other)
    other.is_a?(self.class) && other.random = random
  end

  private

  def current_context
    Thread.current[:consistent_random_context] || Context.new
  end
end
