# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0] - 2025-08-28

### Added
- Initial project setup.
- `README.md`, `CHANGELOG.md`, and `LICENSE` files.
- Japanese version of `README.md` (`README.ja.md`).

### Changed
- Renamed `json-filter.go` to `main.go` for Go conventions.
- Initialized Go module (`go.mod`).
- Simplified `universal-mac` target in `Makefile` to build only macOS universal binary without building other OS binaries.
- Changed binary name from `json-filter-cli` to `json-filter`.
- Modified `release` target in `Makefile` to correctly build and package all binaries, including universal macOS binary.
- Changed release package output directory from `bin/release` to `bin`.

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security