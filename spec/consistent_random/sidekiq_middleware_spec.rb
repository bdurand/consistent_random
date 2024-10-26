# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::SidekiqMiddleware do
  it "wraps a job with a consistent random scope" do
    middleware = ConsistentRandom::SidekiqMiddleware.new
    job = {"args" => {"foo" => "bar"}}
    result = middleware.call(Object, job, "default") do
      expect(ConsistentRandom.new("foo").rand).to eq(ConsistentRandom.new("foo").rand)
      :done
    end
    expect(result).to eq(:done)
  end

  it "adds seeds set in the consistent_random_seeds from the the job payload" do
    value = ConsistentRandom.scope("foobar") { ConsistentRandom.new("foo").rand }

    middleware = ConsistentRandom::SidekiqMiddleware.new
    job = {"args" => {"foo" => "bar"}, "consistent_random_seed" => "foobar"}
    result = middleware.call(Object, job, "default") do
      expect(ConsistentRandom.new("foo").rand).to eq(value)
      :done
    end

    expect(result).to eq(:done)
  end
end
