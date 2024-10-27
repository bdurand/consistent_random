# frozen_string_literal: true

class ConsistentRandom
  # Rack middleware that wraps a request with consistent random scope
  # so that you can generate consistent random values within a request.
  class RackMiddleware
    # @param app [Object] Rack application to wrap
    # @param seed_block [Proc, #call, nil] block to generate seed for the request
    #   If provided, the block will be called with the request env and
    #   the return value will be used as the seed for the request. You can
    #   use this to generate a seed based on the request state..
    def initialize(app, seed_block = nil)
      @app = app
      @seed_block = seed_block
    end

    def call(env)
      seed = @seed_block.call(env) if @seed_block
      ConsistentRandom.scope(seed) do
        @app.call(env)
      end
    end
  end
end
