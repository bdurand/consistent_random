# frozen_string_literal: true

class ConsistentRandom
  # Rack middleware that wraps a request with consistent random scope
  # so that you can generate consistent random values within a request.
  class RackMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      ConsistentRandom.scope do
        @app.call(env)
      end
    end
  end
end
