# frozen_string_literal: true

require_relative "spec_helper"

describe ConsistentRandom do
  describe "#random" do
    it "returns a consistent random number generator for the same name within a scope" do
      ConsistentRandom.scope do
        generator1 = ConsistentRandom.new("foo").random
        generator2 = ConsistentRandom.new("foo").random
        expect(generator1).to eq(generator2)
      end
    end

    it "returns a different random number generator for a different name within a scope" do
      ConsistentRandom.scope do
        generator1 = ConsistentRandom.new("foo").random
        generator2 = ConsistentRandom.new("bar").random
        expect(generator1).not_to eq(generator2)
      end
    end

    it "returns different random number generators for the same name outside a scope" do
      random1 = ConsistentRandom.new("foo")
      random2 = ConsistentRandom.new("foo")
      expect(random1.random).not_to eq(random2.random)
      expect(random1.rand).not_to eq(random2.rand)
      expect(random1.rand).not_to eq(random1.rand)
    end
  end

  describe "#rand" do
    it "returns a consistent random number within a scope" do
      ConsistentRandom.scope do
        rand1 = ConsistentRandom.new("foo").rand
        rand2 = ConsistentRandom.new("foo").rand
        r1 = ConsistentRandom.new("foo").random
        r2 = ConsistentRandom.new("foo").random
        expect(rand1).to eq(rand2)
        expect(r1).to eq(r2)
      end
    end

    it "returns a different random number outside a scope" do
      rand1 = ConsistentRandom.new("foo").rand
      rand2 = ConsistentRandom.new("foo").rand
      expect(rand1).not_to eq(rand2)
    end

    it "can specify a max value" do
      ConsistentRandom.scope do
        value = ConsistentRandom.new("foo").rand(1_000..1_000_000_000)
        expect(value).to be_a(Integer)
        expect(value).to be_between(1_000, 1_000_000_000)
      end
    end
  end

  describe "#bytes" do
    it "returns consistent random bytes within a scope" do
      ConsistentRandom.scope do
        bytes1 = ConsistentRandom.new("foo").bytes(128)
        bytes2 = ConsistentRandom.new("foo").bytes(128)
        expect(bytes1).to eq(bytes2)
      end
    end

    it "returns different random bytes outside a scope" do
      bytes1 = ConsistentRandom.new("foo").bytes(128)
      bytes2 = ConsistentRandom.new("foo").bytes(128)
      expect(bytes1).not_to eq(bytes2)
    end
  end

  describe ".scope" do
    it "creates a scope where consistent random values are generated" do
      ConsistentRandom.scope do
        expect(ConsistentRandom.new("foo").rand).to eq(ConsistentRandom.new("foo").rand)
      end
    end

    it "can nest scopes" do
      ConsistentRandom.scope do
        value1 = ConsistentRandom.new("foo").rand
        value2 = nil
        ConsistentRandom.scope do
          expect(ConsistentRandom.new("foo").rand).to eq(value1)
          value2 = ConsistentRandom.new("bar").rand
        end
        expect(ConsistentRandom.new("bar").rand).not_to eq(value2)
      end
    end

    it "rerturns the result of the block" do
      result = ConsistentRandom.scope do
        :done
      end
      expect(result).to eq(:done)
    end
  end
end
