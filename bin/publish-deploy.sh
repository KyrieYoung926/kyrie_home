#!/usr/bin/env bash
set -euo pipefail

source_root=$(git rev-parse --show-toplevel)
site_dir=$(cd "${1:-_site}" && pwd)
if [[ ! -s "$site_dir/index.html" || -e "$site_dir/.git" || -e "$site_dir/Gemfile" || -e "$site_dir/_config.yml" ]]; then
  echo "Refusing to publish: expected a built static site, not source files." >&2
  exit 1
fi
cd "$source_root"

# Keep the source checkout unchanged, including its checkout-provided credentials.
publish_dir=$(mktemp -d "${TMPDIR:-/tmp}/kyrie-home-deploy.XXXXXX")
cleanup() {
  git worktree remove --force "$publish_dir" >/dev/null 2>&1 || true
  rm -rf -- "$publish_dir"
}
trap cleanup EXIT

parent_args=()
remote_ref=$(git ls-remote --heads origin refs/heads/deploy)
if [[ -n "$remote_ref" ]]; then
  git fetch --no-tags origin refs/heads/deploy
  parent=$(git rev-parse FETCH_HEAD)
  parent_args=(-p "$parent")
fi

git worktree add --detach "$publish_dir" HEAD >/dev/null
find "$publish_dir" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf -- {} +
cp -a "$site_dir/." "$publish_dir/"
touch "$publish_dir/.nojekyll"
git -C "$publish_dir" add --all
site_tree=$(git -C "$publish_dir" write-tree)

if [[ -n "${parent:-}" && "$site_tree" == "$(git rev-parse "$parent^{tree}")" ]]; then
  echo "deploy already contains this build; nothing to publish."
  exit 0
fi

source_sha=$(git rev-parse HEAD)
commit=$(printf 'Publish site from %s\n' "$source_sha" | git \
  -c user.name='github-actions[bot]' \
  -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
  commit-tree "$site_tree" "${parent_args[@]}")
# A normal push preserves history and refuses concurrent/unexpected updates.
git push origin "$commit:refs/heads/deploy"
echo "Published $source_sha to deploy as $commit"
