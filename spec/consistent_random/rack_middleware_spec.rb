# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::RackMiddleware do
  it "wraps a request with a consistent random scope" do
    app = lambda do |env|
      expect(ConsistentRandom.new("foo").rand).to eq(ConsistentRandom.new("foo").rand)
      [200, {v: env[:v]}, ["OK"]]
    end
    middleware = ConsistentRandom::RackMiddleware.new(app)
    response = middleware.call({v: 1})
    expect(response).to eq([200, {v: 1}, ["OK"]])
  end

  it "can specify a block to generate seed for the request" do
    expected_val = ConsistentRandom.scope("foobar") { ConsistentRandom.new("foo").rand }
    app = lambda do |env|
      expect(ConsistentRandom.new("foo").rand).to eq(expected_val)
      [200, {v: env[:v]}, ["OK"]]
    end
    seed_block = lambda { |env| "foobar" }
    middleware = ConsistentRandom::RackMiddleware.new(app, seed_block)
    response = middleware.call({v: 1})
    expect(response).to eq([200, {v: 1}, ["OK"]])
  end
end
