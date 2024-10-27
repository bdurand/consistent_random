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

  if defined?(Sidekiq)
    before do
      Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.clear
        end
        config.client_middleware do |chain|
          chain.clear
        end
      end

      Sidekiq.configure_client do |config|
        config.client_middleware do |chain|
          chain.clear
        end
      end
    end

    it "can install the client middleware" do
      ConsistentRandom::SidekiqMiddleware.install
      Sidekiq.configure_client do |config|
        config.client_middleware do |chain|
          expect(chain.exists?(ConsistentRandom::SidekiqClientMiddleware)).to be(true)
        end
      end
    end

    it "can install the server middleware" do
      ConsistentRandom::SidekiqMiddleware.install
      Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          expect(chain.exists?(ConsistentRandom::SidekiqMiddleware)).to be(true)
        end
        config.client_middleware do |chain|
          expect(chain.exists?(ConsistentRandom::SidekiqClientMiddleware)).to be(true)
        end
      end
    end
  end
end
