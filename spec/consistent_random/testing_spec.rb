# frozen_string_literal: true

require_relative "../spec_helper"

describe ConsistentRandom::Testing do
  describe "rand" do
    it "can specify the random value" do
      ConsistentRandom.testing.rand(0.5) do
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
      end
    end

    it "can specify different values for different names" do
      ConsistentRandom.testing.rand(foo: 0.5, bar: 0.6) do
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
        expect(ConsistentRandom.new("bar").rand).to eq(0.6)
      end
    end

    it "can chain calls to rand" do
      ConsistentRandom.testing.rand(foo: 0.5).rand(bar: 0.6) do
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
        expect(ConsistentRandom.new("bar").rand).to eq(0.6)
      end

      ConsistentRandom.testing.rand(foo: 0.5).rand(0.6) do
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
        expect(ConsistentRandom.new("bar").rand).to eq(0.6)
      end

      ConsistentRandom.testing.rand(0.5).rand(bar: 0.6) do
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
        expect(ConsistentRandom.new("bar").rand).to eq(0.6)
      end
    end

    it "generates a random value if the key does not match" do
      ConsistentRandom.testing.rand(foo: 0.5) do
        rand = ConsistentRandom.new("bar").rand
        expect((0...1).cover?(rand)).to be true
        expect(rand).not_to eq(0.5)
      end
    end

    it "uses the specified value as the base for the random value if a size is specified" do
      ConsistentRandom.testing.rand(foo: 0.5) do
        rand = ConsistentRandom.new("foo").rand(10)
        expect(rand).to eq(5)
      end
    end

    it "raises an error if the value is not a float" do
      expect { ConsistentRandom.testing.rand("foo") }.to raise_error(ArgumentError)
    end

    it "raises an error if the value is not between 0 and 1" do
      expect { ConsistentRandom.testing.rand(2) }.to raise_error(ArgumentError)
    end

    it "raises an error if the value is not a hash of floats" do
      expect { ConsistentRandom.testing.rand(foo: "bar") }.to raise_error(ArgumentError)
    end

    it "raises an error if the value is not a hash of floats between 0 and 1" do
      expect { ConsistentRandom.testing.rand(foo: 2) }.to raise_error(ArgumentError)
    end
  end

  describe "bytes" do
    it "can specify the random bytes" do
      ConsistentRandom.testing.bytes("foo" => "bar") do
        expect(ConsistentRandom.new("foo").bytes(3)).to eq("bar")
      end
    end

    it "can specify different values for different names" do
      ConsistentRandom.testing.bytes(foo: "bar", bar: "baz") do
        expect(ConsistentRandom.new("foo").bytes(3)).to eq("bar")
        expect(ConsistentRandom.new("bar").bytes(3)).to eq("baz")
      end
    end

    it "can chain calls to bytes" do
      ConsistentRandom.testing.bytes(foo: "bar").bytes(bar: "baz") do
        expect(ConsistentRandom.new("foo").bytes(3)).to eq("bar")
        expect(ConsistentRandom.new("bar").bytes(3)).to eq("baz")
      end

      ConsistentRandom.testing.bytes(foo: "bar").bytes("baz") do
        expect(ConsistentRandom.new("foo").bytes(3)).to eq("bar")
        expect(ConsistentRandom.new("bar").bytes(3)).to eq("baz")
      end

      ConsistentRandom.testing.bytes("bar").bytes(bar: "baz") do
        expect(ConsistentRandom.new("foo").bytes(3)).to eq("bar")
        expect(ConsistentRandom.new("bar").bytes(3)).to eq("baz")
      end
    end

    it "returns a string with ASCII-8BIT encoding" do
      ConsistentRandom.testing.bytes(foo: "bar") do
        expect(ConsistentRandom.new("foo").bytes(3).encoding).to eq(Encoding::ASCII_8BIT)
      end
    end

    it "generates random bytes if the key does not match" do
      ConsistentRandom.testing.bytes(foo: "bar") do
        bytes = ConsistentRandom.new("baz").bytes(3)
        expect(bytes).to be_a(String)
        expect(bytes.length).to eq(3)
      end
    end

    it "uses the specified value as the base for the random bytes if a size is specified" do
      ConsistentRandom.testing.bytes(foo: "bar") do
        expect(ConsistentRandom.new("foo").bytes(7)).to eq("barbarb")
        expect(ConsistentRandom.new("foo").bytes(2)).to eq("ba")
      end
    end

    it "raises an error if the value is not a string" do
      expect { ConsistentRandom.testing.bytes(1) }.to raise_error(ArgumentError)
    end

    it "raises an error if the value is not a hash of strings" do
      expect { ConsistentRandom.testing.bytes("foo" => 1) }.to raise_error(ArgumentError)
    end
  end

  describe "seed" do
    it "can specify the seed value" do
      ConsistentRandom.testing.seed(123) do
        expect(ConsistentRandom.new("foo").seed).to eq(123)
      end
    end

    it "can specify different values for different names" do
      ConsistentRandom.testing.seed(foo: 123, bar: 456) do
        expect(ConsistentRandom.new("foo").seed).to eq(123)
        expect(ConsistentRandom.new("bar").seed).to eq(456)
      end
    end

    it "can chain calls to seed" do
      ConsistentRandom.testing.seed(foo: 123).seed(bar: 456) do
        expect(ConsistentRandom.new("foo").seed).to eq(123)
        expect(ConsistentRandom.new("bar").seed).to eq(456)
      end

      ConsistentRandom.testing.seed(foo: 123).seed(456) do
        expect(ConsistentRandom.new("foo").seed).to eq(123)
        expect(ConsistentRandom.new("bar").seed).to eq(456)
      end

      ConsistentRandom.testing.seed(123).seed(bar: 456) do
        expect(ConsistentRandom.new("foo").seed).to eq(123)
        expect(ConsistentRandom.new("bar").seed).to eq(456)
      end
    end

    it "generates a random seed if the key does not match" do
      ConsistentRandom.testing.seed(foo: 123) do
        seed = ConsistentRandom.new("bar").seed
        expect(seed).to be_a(Integer)
        expect(seed).not_to eq(123)
      end
    end

    it "raises an error if the value is not an integer" do
      expect { ConsistentRandom.testing.seed("foo") }.to raise_error(ArgumentError)
    end

    it "raises an error if the value is not a hash of integers" do
      expect { ConsistentRandom.testing.seed(foo: "bar") }.to raise_error(ArgumentError)
    end
  end

  describe "use" do
    it "can nest testing blocks" do
      ConsistentRandom.testing.rand(0.5) do
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
        ConsistentRandom.testing.rand(0.6) do
          expect(ConsistentRandom.new("foo").rand).to eq(0.6)
        end
        expect(ConsistentRandom.new("foo").rand).to eq(0.5)
      end
    end

    it "returns the result of the block" do
      result = ConsistentRandom.testing.rand(0.5) { :foobar }
      expect(result).to eq(:foobar)
    end
  end
end
