# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::SidekiqClientMiddleware do
  it "adds the current seeds to the job payload if the consistent_random option is set" do
    middleware = ConsistentRandom::SidekiqClientMiddleware.new
    job = {"args" => {"foo" => "bar"}}
    result = ConsistentRandom.scope("foobar") do
      middleware.call(Object, job, "default", :redis_pool) do
        :done
      end
    end
    expect(result).to eq(:done)
    expect(job["consistent_random_seed"]).to eq("foobar")
  end

  it "does not add the current seeds to the job payload if the consistent_random option is false" do
    middleware = ConsistentRandom::SidekiqClientMiddleware.new
    job = {"args" => {"foo" => "bar"}, "consistent_random" => true}
    result = ConsistentRandom.scope do
      middleware.call(Object, job, "default", :redis_pool) do
        :done
      end
    end
    expect(result).to eq(:done)
    expect(job).not_to have_key("consistent_random_seeds")
  end

  it "does not add the current seeds to the job payload if there are no seeds" do
    middleware = ConsistentRandom::SidekiqClientMiddleware.new
    job = {"args" => {"foo" => "bar"}, "consistent_random" => true}
    result = middleware.call(Object, job, "default", :redis_pool) do
      :done
    end
    expect(result).to eq(:done)
    expect(job).not_to include("consistent_random_seeds")
  end
end
