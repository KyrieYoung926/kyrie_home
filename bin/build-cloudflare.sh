#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Legacy direct-build entry point. Cloudflare should now serve the deploy branch.
# Use the same Bundler as Gemfile.lock for optional local/direct builds.
gem install bundler --version 4.0.6 --no-document
export BUNDLE_PATH="${BUNDLE_PATH:-vendor/bundle}"
export BUNDLE_FROZEN=true
export JEKYLL_ENV=production
bundle _4.0.6_ install --jobs 4 --retry 3
exec bash bin/build-site.sh "$@"
