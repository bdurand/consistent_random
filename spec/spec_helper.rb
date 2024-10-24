# frozen_string_literal: true

require "bundler/setup"

require_relative "../lib/consistent_random"

begin
  require "active_job"
rescue LoadError
end

ActiveJob::Base.logger = nil if defined?(ActiveJob)

RSpec.configure do |config|
  config.order = :random
end
