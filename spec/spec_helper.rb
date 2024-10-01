# frozen_string_literal: true

require "bundler/setup"

require_relative "../lib/consistent_random"

RSpec.configure do |config|
  config.order = :random
end
