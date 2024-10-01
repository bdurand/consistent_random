# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::SidekiqMiddleware do
  it "wraps a job with a consistent random scope" do
    middleware = ConsistentRandom::SidekiqMiddleware.new
    job = {"args" => {"foo" => "bar"}}
    result = middleware.call(Object, job, "default") do
      expect(ConsistentRandom.new("foo").random).to eq(ConsistentRandom.new("foo").random)
      :done
    end
    expect(result).to eq(:done)
  end
end
