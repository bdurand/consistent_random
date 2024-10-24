# frozen_string_literal: true

require_relative "../spec_helper"

if defined?(ActiveJob)
  class TestJob < ActiveJob::Base
    include ConsistentRandom::ActiveJob

    def perform(key)
      [ConsistentRandom.new(key).rand, ConsistentRandom.new(key).rand]
    end
  end

  describe ConsistentRandom::ActiveJob do
    it "wraps a job with a consistent random scope" do
      result = TestJob.perform_now("foo")
      expect(result[0]).to eq(result[1])
    end

    it "persists seeds from the current scope" do
      job_data = nil
      value = nil
      ConsistentRandom.scope(123) do
        job_data = TestJob.new("foo").serialize
        value = ConsistentRandom.new("foo").rand
      end
      result = TestJob.execute(job_data)
      expect(result).to eq([value, value])
    end

    it "can be disabled by setting consistent_random to false" do
      TestJob.inherit_consistent_random_scope = false
      job_data = ConsistentRandom.scope(123) { TestJob.new("foo").serialize }
      result = TestJob.execute(job_data)
      expect(result[0]).not_to eq(123)
      expect(result[0]).to eq(result[1])
    ensure
      TestJob.inherit_consistent_random_scope = nil
    end
  end
end
