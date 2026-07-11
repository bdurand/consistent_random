# frozen_string_literal: true

require "bundler/setup"

# Needed for loading Rails 6.x and 7.0
begin
  require "logger"
rescue LoadError
end

require_relative "../lib/consistent_random"

begin
  require "active_job"
rescue LoadError
end

begin
  require "sidekiq"
rescue LoadError
end

ActiveJob::Base.logger = nil if defined?(ActiveJob)

RSpec.configure do |config|
  config.order = :random
end
