# Constant Random

[![Continuous Integration](https://github.com/bdurand/consistent_random/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/consistent_random/actions/workflows/continuous_integration.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/consistent_random.svg)](https://badge.fury.io/rb/consistent_random)

## Introduction

This Ruby gem allows you to generate consistent random values tied to a specific name within a defined scope. It ensures that random behavior remains consistent within a particular context, such as handling feature rollouts.

For example, consider rolling out a new feature to a subset of requests, such as enabling the feature for 10% of requests. You want to randomize which requests get the new feature, but ensure that within each request, the feature is consistently enabled or disabled across all actions. This gem allows you to achieve that by tying random values to specific names and defining a scope. Within that scope, the same value will be consistently generated for each named variable.

## Usage

To generate consistent random values, you need to define a scope. You do this with the `ConsistentRandom.scope` method. Within the scope block, calls to `ConsistentRandom` will return the same random values for the same name.

```ruby
ConsistentRandom.scope do
  random = ConsistentRandom.new("foobar")
  a = random.rand(100) # Generates a random number between 0 and 99 tied to "foobar"
  b = random.rand(100) # Same random number as 'a', because "foobar" is reused
  a == b # => true
end
```

This can be used to implement things like feature flags for rolling out new features on a percentage of your requests.

```ruby
class FeatureFlag
  def initialize(name, roll_out_percentage)
    @name = name
    @roll_out_percentage = roll_out_percentage
  end

  def enabled?
    ConsistentRandom.new("FeatureFlag.#{@name}").rand < @roll_out_percentage
  end
end
```

Checking a feature flag will return the same value within a scope.

```ruby
class MyService
  def call(arg)
    if FeatureFlag.new("new_feature", 0.1).enabled?
      # Do something new 10% of the time
    else
      # Do something else
    end
  end
end

ConsistentRandom.scope do
  things.each do |thing|
    MyService.new.call(thing) # You won't get a mix of new and old behavior within this iteration
  end
end
```

If there is no scope defined, the random values will be different each time for different instances of `ConsistentRandom`. So, if your code is executed outside of a scope, it will still work but with random values being generated rather than consistent values.

```ruby
random = ConsistentRandom.new("foobar")
random.rand != random.rand # => true
```

### Middlewares

The gem provides built-in middlewares for Rack and Sidekiq, automatically scoping requests and jobs. This ensures that consistent random values are generated within the request/job context.

#### Rack Middleware

In a Rack application:

```ruby
Rack::Builder.app do
  use ConsistentRandom::RackMiddleware
  run MyApp
end
```

Or in a Rails application:

```ruby
# config/application.rb
config.middleware.use ConsistentRandom::RackMiddleware
```

#### Sidekiq Middleware

Add the middleware to your Sidekiq server configuration:

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add ConsistentRandom::SidekiqMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add ConsistentRandom::SidekiqClientMiddleware
  end
end
```

Consistent random values will be propagated from the original request to any Sidekiq jobs. You can disable this behavior by setting the `conistent_random` sidekiq option to `false`:

```ruby
class MyWorker
  include Sidekiq::Job

  sidekiq_options consistent_random: false

  def perform
    # Each job will use it's own random scope.
  end
end
```

### ActiveJob

You can use consistent random values in your ActiveJob jobs by including the `ConsistentRandom::ActiveJob` module:

```ruby
class MyJob < ApplicationJob
  include ConsistentRandom::ActiveJob

  def perform
    # Job will use consistent random values using the same scope from when it was enqueued.
  end
end
```

You can force a job to use it's own random scope by setting the `consistent_random` option to `false`:

```ruby
class MyJob < ApplicationJob
  include ConsistentRandom::ActiveJob

  self.inherit_consistent_random_scope = false

  def perform
    # Job will use it's own random scope.
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "consistent_random"
```

Then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install consistent_random
```

## Contributing

Open a pull request on [GitHub](https://github.com/bdurand/consistent_random).

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
