# frozen_string_literal: true

appraise "no_dependencies" do
  remove_gem "activejob"
  remove_gem "sidekiq"
end

appraise "activejob_7" do
  gem "activejob", "~> 7.0.0"
  remove_gem "sidekiq"
end

appraise "activejob_6" do
  gem "activejob", "~> 6.0.0"
  remove_gem "sidekiq"
end

appraise "sidekiq_7" do
  gem "sidekiq", "~> 7.0.0"
  remove_gem "activejob"
end

appraise "sidekiq_6" do
  gem "sidekiq", "~> 6.0.0"
  remove_gem "activejob"
end
