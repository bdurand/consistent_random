# frozen_string_literal: true

require "digest/sha1"
require "securerandom"

class ConsistentRandom
  SEED_DIVISOR = (2**64 - 1).to_f
  private_constant :SEED_DIVISOR

  autoload :RackMiddleware, "consistent_random/rack_middleware"
  autoload :SidekiqMiddleware, "consistent_random/sidekiq_middleware"
  autoload :SidekiqClientMiddleware, "consistent_random/sidekiq_client_middleware"
  autoload :ActiveJob, "consistent_random/active_job"

  class << self
    # Define a scope where consistent random values will be generated.
    #
    # @param seeds [String, Symbol, Integer, Array<String>, Array<Integer>, nil] optional value to
    #   use for generating random numbers. By default a random value will be generated. If the
    #   scope is nested in another scope block, then the seed from the parent scope will be used
    #   by default.
    # @yield block of code to execute within the scope
    # @return the result of the block
    def scope(seed = nil)
      existing_seed = Thread.current[:consistent_random_seed]
      seed_value = case seed
      when nil
        existing_seed || SecureRandom.hex
      when String, Symbol, Integer
        seed.to_s
      when Array
        seed.map { |s| s.to_s }.join("\x1C")
      else
        raise ArgumentError, "Invalid seed value: #{seed.inspect}"
      end

      begin
        Thread.current[:consistent_random_seed] = seed_value
        yield
      ensure
        Thread.current[:consistent_random_seed] = existing_seed
      end
    end

    # Get the current seed used to generate random numbers. This will return nil if called
    # outside of a scope.
    #
    # @return [String, nil] the seed value for the current scope
    #  or nil if called outside of a scope.
    # @api private
    def current_seed
      Thread.current[:consistent_random_seed]
    end

    def testing
      Testing.new
    end
  end

  attr_reader :name

  # @param name [Object] a name used to identifuy a consistent random value
  def initialize(name)
    @name = (name.is_a?(String) ? name.dup : name.to_s).freeze
  end

  # Generate a random number. The same number will be generated within a scope block.
  # This method works the same as Kernel#rand. It will generate a consistent value even
  # across Ruby versions and platforms.
  #
  # @param max [Integer, Range] the maximum value of the random float or a range indicating
  #  the minimum and maximum values.
  # @return [Numeric] a random number. If the max argument is a range, then the result will be
  #   a number in that range. If max is an number, then it will be an integer between 0 and that
  #   value. Otherwise, it will be a float between 0 and 1.
  def rand(max = nil)
    value = Testing.current&.rand_for(name) || seed / SEED_DIVISOR
    case max
    when nil
      value
    when Numeric
      (value * max.to_i).to_i
    when Range
      cap_to_range(value, max)
    end
  end

  # Generate a random array of bytes. The same number will be generated within a scope block.
  # This method works the same as Random#bytes.
  #
  # @param size [Integer] the number of bytes to generate.
  # @return [String] a string of random bytes.
  def bytes(size)
    test_bytes = Testing.current&.bytes_for(name)
    test_bytes = nil if test_bytes&.empty?
    chunk_size = (test_bytes ? test_bytes.length : 20)

    bytes = []
    (size / chunk_size.to_f).ceil.times do |i|
      bytes << (test_bytes || seed_hash("#{name}#{i}").to_s)
    end
    bytes.join[0, size]
  end

  # Generate a seed that can be used to generate random numbers. This seed will be
  # return a consistent value when called within a scope.
  #
  # @return [Integer] a 64 bit integer for seeding random values
  def seed
    test_seed = Testing.current&.seed_for(name)
    return test_seed if test_seed

    hash = seed_hash(name)
    hash.byteslice(0, 8).unpack1("Q>")
  end

  # @return [Boolean] true if the other object is a ConsistentRandom that returns
  #   the same random number generator. If called outside of a scope, then it will
  #   always return false. The functionality is designed to be similar to the
  #   same behavior as Random.
  def ==(other)
    other.is_a?(self.class) && other.seed == seed
  end

  # Generate a random number generator for the given name. The generator will always
  # have the same seed within a scope.
  #
  # This value is dependent on the Ruby Random class and may not generate consistent values
  # across Ruby versions and platforms.
  #
  # @return [Random] a random number generator
  def random
    Random.new(seed)
  end

  private

  def seed_hash(name)
    random_seed = self.class.current_seed || SecureRandom.hex
    Digest::SHA1.digest("#{random_seed}\x1C#{name}")
  end

  def cap_to_range(value, range)
    min = range.begin
    max = range.end
    if min.nil? || max.nil?
      raise ArgumentError, "Cannot generate random value for infinite range"
    end

    int_range = min.is_a?(Integer) && max.is_a?(Integer)
    max += 1 if int_range && range.include?(max)

    val = (value * (max - min)) + min
    int_range ? val.to_i : val
  end
end

require_relative "consistent_random/testing"
