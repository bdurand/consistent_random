# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.3.0

### Fixed

- `ConsistentRandom#rand` can no longer return an out of range value. Previously there was a very small chance (about 1 in 2⁵³) that a seed could produce a value of exactly 1.0, causing `rand` to return 1.0, `rand(n)` to return `n`, and `rand(range)` to return a value above the range. Random floats are now derived from the top 53 bits of the seed, guaranteeing a uniform value in `[0, 1)`. **Note:** this changes the exact values generated for existing seeds (the distribution is unchanged), so percentage rollouts in flight during an upgrade may reassign.
- Fixed distribution bias in `ConsistentRandom#rand` for ranges with negative bounds. Values were truncated toward zero instead of floored, so for a range like `-5..5` the minimum value was never returned and zero was returned twice as often as other values.
- `ConsistentRandom#rand` now raises an `ArgumentError` for empty ranges (e.g. `5..1`) and non-numeric ranges instead of returning out of range values or raising a `NoMethodError`.
- `ConsistentRandom::Testing#bytes` now raises an `ArgumentError` for empty strings, which were previously accepted but silently ignored, producing non-deterministic values in tests.

### Changed

- `ConsistentRandom.current_seed` is now public API; it can be used to propagate a scope into threads or fibers, which do not inherit the fiber-local scope state.

## 2.2.0

### Added

- Added `ConsistentRandom.testing` method to allow for deterministic testing of random values.
- Added `ConsistentRandom#name` method to return the name used for seeding the random value.

## 2.1.1

### Fixed

- Fixed typo in `==` method which caused a NoMethodError when comparing ConsistentRandom instances.

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
