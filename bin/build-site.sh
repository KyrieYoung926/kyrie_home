#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# al_folio_core scans Markdown with File.foreach (Ruby's default encoding).
# Jekyll's YAML encoding option alone does not affect that scan.
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export RUBYOPT=-EUTF-8:UTF-8
export JEKYLL_ENV=production
bundle exec ruby -e 'abort "Ruby must read files as UTF-8" unless Encoding.default_external == Encoding::UTF_8'
exec bundle exec jekyll build "$@"
