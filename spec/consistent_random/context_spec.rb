# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::Context do
  it "returns a consistent seed for a given name" do
    context = ConsistentRandom::Context.new
    seed1 = context.seed("foo")
    seed2 = context.seed("foo")
    expect(seed1).to eq(seed2)
  end

  it "returns a different seed for a different name" do
    context = ConsistentRandom::Context.new
    seed1 = context.seed("foo")
    seed2 = context.seed("bar")
    expect(seed1).not_to eq(seed2)
  end

  it "merges seeds from an existing context" do
    existing_context = ConsistentRandom::Context.new
    existing_seed = existing_context.seed("foo")
    context = ConsistentRandom::Context.new(existing_context)

    new_seed = context.seed("foo")
    expect(new_seed).to eq(existing_seed)
    expect(context.seed("bar")).not_to eq(existing_context.seed("bar"))
  end
end
