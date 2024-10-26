# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.1.0

### Added

- Added optional seed block to the Rack middleware to allow for custom seed values based on the request.
- Added helper method `ConsistentRandom::SidekiqMiddleware.install` to install both the client and server middlewares in one call.

## 2.0.0

### Changed

- `ConsistentRandom#rand` uses a faster hashing algorithm for generating random values. This will make the value consistent across different Ruby versions and platforms.

### Added

- Added `ConsistentRandom::SidekiqClientMiddleware` to allow persisting consistent random seeds to Sidekiq jobs so behavior is consistent between when jobs are enqueued and when they are executed.
- Added `ConsistentRandom::ActiveJob` for hooking into ActiveJob to persist consistent random seeds to jobs.

## 1.0.0

### Added
- Initial release.
