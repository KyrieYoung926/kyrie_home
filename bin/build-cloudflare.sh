#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Use the same Bundler as Gemfile.lock; Cloudflare's default can be older.
gem install bundler --version 4.0.6 --no-document
export BUNDLE_PATH="${BUNDLE_PATH:-vendor/bundle}"
export BUNDLE_FROZEN=true
export JEKYLL_ENV=production
bundle _4.0.6_ install --jobs 4 --retry 3
bundle _4.0.6_ exec jekyll build
