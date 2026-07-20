# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

begin
  require "simplecov"
  SimpleCov.start do
    add_filter ["/spec/"]
  end
rescue LoadError
end

Bundler.require(:default, :test)

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
  config.warnings = true
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end
