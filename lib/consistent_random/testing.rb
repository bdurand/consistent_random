# frozen_string_literal: true

class ConsistentRandom
  # This class returns an object that can be used to generate deterministic values
  # for use in testing.
  #
  # @example
  #  ConsistentRandom.testing.rand(foo: 0.5).bytes(foo: "foobar").seed(123) do
  #    expect(ConsistentRandom.new("foo").rand).to eq(0.5)
  #    expect(ConsistentRandom.new("bar").rand).not_to eq(0.5)
  #
  #    expect(ConsistentRandom.new("foo").bytes(12)).to eq("foobarfoobar")
  #
  #    expect(ConsistentRandom.new("foo").seed).to eq(123)
  #  end
  class ConsistentRandom::Testing
    class << self
      # Get the testing object if any for the current block.
      #
      # @return [ConsistentRandom::Testing, nil] the testing object or nil if not set
      # @api private
      def current
        Thread.current[:consistent_random_testing]
      end
    end

    def initialize
      @rand_hash = {}
      @bytes_hash = {}
      @seed_hash = {}
    end

    # Set the random value returned by ConsistentRandom#rand.
    #
    # param options [Float, Hash<String, Float>] the value to return for rand. If a Float is given
    #  then it will be used as the value for all calls to rand. If a Hash is given then the value
    #  will only be returned for ConsitentRandom objects with the names specified in the keys.
    # @yield block of code to execute with the test values.
    # @return [ConsistentRandom::Testing, Object] If a block is specified, then the result
    #   of the block is returned. Otherwise the testing object is returned so that you can
    #   chain calls to set up more test values.
    def rand(options, &block)
      options = validate_rand(options)
      unless options
        raise ArgumentError.new("Argument must be a Float between 0 and 1 or a Hash with Float values")
      end

      @rand_hash = options.default ? options.merge(@rand_hash) : @rand_hash.merge(options)
      if block
        use(&block)
      else
        self
      end
    end

    # Set the random bytes returned by ConsistentRandom#bytes.
    #
    # param options [String, Hash<String, String>] the value to return for bytes. If a String is given
    #  then it will be used as the value for all calls to bytes. If a Hash is given then the value
    #  will only be returned for ConsitentRandom objects with the names specified in the keys.
    # @yield block of code to execute with the test values.
    # @return [ConsistentRandom::Testing, Object] If a block is specified, then the result
    #   of the block is returned. Otherwise the testing object is returned so that you can
    #   chain calls to set up more test values.
    def bytes(options, &block)
      options = validate_bytes(options)
      unless options
        raise ArgumentError.new("Argument must be a String or a Hash with String values")
      end

      @bytes_hash = options.default ? options.merge(@bytes_hash) : @bytes_hash.merge(options)
      if block
        use(&block)
      else
        self
      end
    end

    # Set the seed value returned by ConsistentRandom#seed.
    #
    # param options [Integer, Hash<String, Integer>] the value to return for seed. If an Integer is given
    #   then it will be used as the value for all calls to seed. If a Hash is given then the value
    #   will only be returned for ConsitentRandom objects with the names specified in the keys.
    # @yield block of code to execute with the test values.
    # @return [ConsistentRandom::Testing, Object] If a block is specified, then the result
    #   of the block is returned. Otherwise the testing object is returned so that you can
    #   chain calls to set up more test
    def seed(options, &block)
      options = validate_seed(options)
      unless options
        raise ArgumentError.new("Argument must be an Integer or a Hash with Integer values")
      end

      @seed_hash = options.default ? options.merge(@seed_hash) : @seed_hash.merge(options)
      if block
        use(&block)
      else
        self
      end
    end

    # Use the test values within a block of code.
    #
    # @yield block of code to execute with the test values.
    # @return [Object] the result of the block
    def use(&block)
      save_val = Thread.current[:consistent_random_testing]
      begin
        Thread.current[:consistent_random_testing] = self
        yield
      ensure
        Thread.current[:consistent_random_testing] = save_val
      end
    end

    # Get the test value for rand.
    #
    # @param name [String] the name of the ConsistentRandom object
    # @return [Float, nil] the test value for rand if there is a test value for the name
    # @api private
    def rand_for(name)
      @rand_hash[name]
    end

    # Get the test value for bytes.
    #
    # @param name [String] the name of the ConsistentRandom object
    # @return [String, nil] the test value for bytes if there is a test value for the name
    # @api private
    def bytes_for(name)
      @bytes_hash[name]
    end

    # Get the test value for seed.
    #
    # @param name [String] the name of the ConsistentRandom object
    # @return [Integer, nil] the test value for seed if there is a test value for the name
    # @api private
    def seed_for(name)
      @seed_hash[name]
    end

    private

    def validate_rand(options)
      if options.is_a?(Hash) && options.values.all? { |value| value.is_a?(Float) && (0...1).cover?(value) }
        options.each_with_object({}) { |(key, value), hash| hash[key.to_s] = value }
      elsif options.is_a?(Float) && (0...1).cover?(options)
        Hash.new(options)
      end
    end

    def validate_bytes(options)
      if options.is_a?(Hash) && options.values.all? { |value| value.is_a?(String) }
        options.each_with_object({}) { |(key, value), hash| hash[key.to_s] = value.encode(Encoding::ASCII_8BIT) }
      elsif options.is_a?(String)
        Hash.new(options)
      end
    end

    def validate_seed(options)
      if options.is_a?(Hash) && options.values.all? { |value| value.is_a?(Integer) }
        options.each_with_object({}) { |(key, value), hash| hash[key.to_s] = value }
      elsif options.is_a?(Integer)
        Hash.new(options)
      end
    end
  end
end
