#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "$0")" && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/kyrie-home-publish-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

git init --bare --initial-branch=main "$test_dir/remote.git" >/dev/null
git init --initial-branch=main "$test_dir/source" >/dev/null
cd "$test_dir/source"
git config user.name 'Publication test'
git config user.email 'test@example.invalid'
git remote add origin "$test_dir/remote.git"
printf 'source-only file\n' > README.md
git add README.md
git commit -m 'Source fixture' >/dev/null
git push origin main >/dev/null
source_sha=$(git rev-parse HEAD)

mkdir -p "$test_dir/site/assets" "$test_dir/site/.well-known"
printf '<h1>Xun Kyrie Yang — UTF-8 ✓</h1>\n' > "$test_dir/site/index.html"
printf '\000\001\377\200' > "$test_dir/site/assets/sample.bin"
printf 'keep dotfiles\n' > "$test_dir/site/.well-known/example"
printf 'will be removed\n' > "$test_dir/site/stale.html"
bash "$script_dir/publish-deploy.sh" "$test_dir/site"
git clone --quiet --branch deploy "$test_dir/remote.git" "$test_dir/output"
first_deploy=$(git -C "$test_dir/output" rev-parse HEAD)
[[ $(git -C "$test_dir/output" rev-list --count HEAD) == 1 ]]
[[ ! -e "$test_dir/output/README.md" ]]
[[ -f "$test_dir/output/.nojekyll" ]]
[[ -f "$test_dir/output/.well-known/example" ]]
cmp "$test_dir/site/index.html" "$test_dir/output/index.html"
cmp "$test_dir/site/assets/sample.bin" "$test_dir/output/assets/sample.bin"

# Repeating an unchanged build should not create another commit.
bash "$script_dir/publish-deploy.sh" "$test_dir/site"
[[ $(git --git-dir="$test_dir/remote.git" rev-parse deploy) == "$first_deploy" ]]

# New builds retain deploy history and remove files absent from the new output.
rm "$test_dir/site/stale.html"
printf '<h1>Updated — still UTF-8 ✓</h1>\n' > "$test_dir/site/index.html"
bash "$script_dir/publish-deploy.sh" "$test_dir/site"
git -C "$test_dir/output" pull --ff-only >/dev/null
[[ $(git -C "$test_dir/output" rev-parse HEAD^) == "$first_deploy" ]]
[[ ! -e "$test_dir/output/stale.html" ]]
cmp "$test_dir/site/index.html" "$test_dir/output/index.html"
[[ $(git --git-dir="$test_dir/remote.git" rev-parse main) == "$source_sha" ]]
[[ $(git rev-parse HEAD) == "$source_sha" ]]
[[ -z $(git status --porcelain) ]]
[[ $(git worktree list --porcelain | sed -n '/^worktree /p' | wc -l) == 1 ]]

# Reject source directories and missing output without touching deploy.
last_deploy=$(git --git-dir="$test_dir/remote.git" rev-parse deploy)
printf 'source metadata\n' > "$test_dir/site/Gemfile"
if bash "$script_dir/publish-deploy.sh" "$test_dir/site"; then
  echo 'ERROR: publisher accepted source metadata' >&2; exit 1
fi
if bash "$script_dir/publish-deploy.sh" "$test_dir/nonexistent"; then
  echo 'ERROR: publisher accepted missing output' >&2; exit 1
fi
[[ $(git --git-dir="$test_dir/remote.git" rev-parse deploy) == "$last_deploy" ]]
echo 'Deploy publisher integration tests passed.'
