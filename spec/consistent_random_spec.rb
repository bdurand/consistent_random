# frozen_string_literal: true

require_relative "spec_helper"

describe ConsistentRandom do
  describe "#name" do
    it "has a name" do
      expect(ConsistentRandom.new("foo").name).to eq("foo")
    end
  end

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

    it "generates a value within an inclusive range" do
      distribution = Hash.new(0)
      2000.times do
        ConsistentRandom.scope do
          value = ConsistentRandom.new("foo").rand(2..4)
          distribution[value] += 1
        end
      end
      expect(distribution.keys).to match_array([2, 3, 4])
    end

    it "generates a value within a exclusive range" do
      distribution = Hash.new(0)
      2000.times do
        ConsistentRandom.scope do
          value = ConsistentRandom.new("foo").rand(2...5)
          distribution[value] += 1
        end
      end
      expect(distribution.keys).to match_array([2, 3, 4])
    end
  end

  describe "#bytes" do
    it "returns an ascii string of random bytes" do
      bytes = ConsistentRandom.new("foo").bytes(128)
      expect(bytes.length).to eq(128)
      expect(bytes.encoding).to eq(Encoding::ASCII_8BIT)
    end

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

    it "can change the seed in a nested scope" do
      expected_val = ConsistentRandom.scope(123) { ConsistentRandom.new("foo").rand }
      ConsistentRandom.scope do
        value = ConsistentRandom.new("foo").rand
        ConsistentRandom.scope(123) do
          expect(ConsistentRandom.new("foo").rand).not_to eq(value)
          expect(ConsistentRandom.new("foo").rand).to eq(expected_val)
        end
        expect(ConsistentRandom.new("foo").rand).to eq(value)
      end
    end

    it "returns the result of the block" do
      result = ConsistentRandom.scope do
        :done
      end
      expect(result).to eq(:done)
    end

    it "can manually specify the scope seed" do
      value_1 = ConsistentRandom.scope("foobar") { ConsistentRandom.new("foo").rand }
      value_2 = ConsistentRandom.scope("foobar") { ConsistentRandom.new("foo").rand }
      expect(value_1).to eq(value_2)
    end

    it "can specify an integer as the scope seed" do
      value_1 = ConsistentRandom.scope(123) { ConsistentRandom.new("foo").rand }
      value_2 = ConsistentRandom.scope(123) { ConsistentRandom.new("foo").rand }
      expect(value_1).to eq(value_2)
    end

    it "can specify an array as the scope seed" do
      value_1 = ConsistentRandom.scope([1, 2, 3]) { ConsistentRandom.new("foo").rand }
      value_2 = ConsistentRandom.scope([1, 2, 3]) { ConsistentRandom.new("foo").rand }
      expect(value_1).to eq(value_2)
    end
  end

  describe ".eq?" do
    it "returns true if the values have the same seed" do
      random_1 = ConsistentRandom.new("foo")
      random_2 = ConsistentRandom.new("foo")
      expect(random_1).to_not eq(random_2)
      ConsistentRandom.scope do
        expect(random_1).to eq(random_2)
      end
    end

    it "return false if the comparison value is not a ConsistentRandom" do
      expect(ConsistentRandom.new("foo")).not_to eq("foo")
    end
  end
end
