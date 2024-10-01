# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::RackMiddleware do
  it "wraps a request with a consistent random scope" do
    app = lambda do |env|
      expect(ConsistentRandom.new("foo").random).to eq(ConsistentRandom.new("foo").random)
      [200, {v: env[:v]}, ["OK"]]
    end
    middleware = ConsistentRandom::RackMiddleware.new(app)
    response = middleware.call({v: 1})
    expect(response).to eq([200, {v: 1}, ["OK"]])
  end
end
