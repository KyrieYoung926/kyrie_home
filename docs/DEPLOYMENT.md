# Deployment and encoding investigation

## Root cause and fix

The exact reported failure was reproduced with `LANG=C LC_ALL=C`: Ruby's `Encoding.default_external` becomes `US-ASCII`. In `al_folio_core` 1.0.15, `legacy_hits` reads Markdown via `File.foreach` without an explicit encoding and applies a regular expression at `al_folio_core.rb:179`. Valid UTF-8 text such as em dashes and Chinese characters is then treated as invalid US-ASCII.

`bin/build-site.sh` sets `LANG=C.UTF-8`, `LC_ALL=C.UTF-8`, and sets `RUBYOPT=-EUTF-8:UTF-8` (replacing any conflicting inherited encoding flags) before invoking Jekyll. It verifies Ruby's default external encoding. This covers the gem's direct file reads without modifying the pinned gem, removing Unicode from content, or changing `_config.yml`. Setting only Jekyll's `encoding` option would not control that `File.foreach` call.

The workflow sets the same UTF-8 environment before dependency setup. The old `bin/build-cloudflare.sh` remains a compatible optional dependency-install entry point and delegates its Jekyll build to the fixed script. Cloudflare no longer needs to run either script once configured for `deploy`.

## Workflow behavior

- Trigger: pushes to `main`, or `workflow_dispatch` on `main`.
- Runtime: Ubuntu 24.04, Ruby from `.ruby-version` (3.3.6), Bundler 4.0.6, Node.js 22 for JavaScript minification.
- Official setup actions are pinned to full commit SHAs. `ruby/setup-ruby` caches the locked dependencies.
- Publication uses only `GITHUB_TOKEN`, with job-scoped `contents: write` and checkout's Git authentication.
- Runs are serialized with a concurrency group. Publication occurs only after the build and publisher integration tests succeed.
- `bin/publish-deploy.sh` copies the generated site into an isolated Git worktree. Its first commit has no source-history parent; subsequent commits descend from the last `deploy` commit. It uses a normal push, not a force push.
- `deploy` contains `index.html`, page directories, assets, and `.nojekyll` at its root. It contains no Gemfile, workflow, or build scripts. Files removed from the new output are removed from the branch. An identical tree produces no new commit.
- The source checkout and `main` are unchanged by publication. Failed builds and failed pushes do not overwrite a successful deploy branch.
- GitHub Actions does not run again for this generated branch: the workflow is filtered to `main`, and the generated branch contains no workflow file. Cloudflare's Git integration should watch `deploy`, not `main`.

## Local verification

After installing the dependencies with Ruby 3.3.6 / Bundler 4.0.6:

```bash
# Regression test: deliberately start with an ASCII locale and Ruby encoding.
LANG=C LC_ALL=C RUBYOPT=-EUS-ASCII bash bin/build-site.sh

# Tests against disposable local Git repositories, never GitHub or Cloudflare.
bash bin/test-publish.sh

# Shell syntax checks.
bash -n bin/build-site.sh bin/build-cloudflare.sh bin/publish-deploy.sh bin/test-publish.sh

# Optional workflow and shell lint, with actionlint/shellcheck installed.
actionlint .github/workflows/deploy.yml
```

The publisher integration test covers first publication, exact UTF-8/binary copying, dotfiles, unchanged builds, incremental history, deleted output files, main/source preservation, worktree cleanup, and refusal to publish a source directory or missing build output.

The local tests do not simulate GitHub's hosted runner, token permissions, or Cloudflare's webhook delivery. Confirm the first real Actions run and the corresponding Pages deployment after pushing and changing the settings in README.

## Manual setup and troubleshooting

Use the tables in [README](../README.md#manual-cloudflare-pages-setup). Set the production branch to `deploy`, build command to `exit 0`, and output directory to `.`. Disable preview branch deployments; otherwise Cloudflare may try to serve unbuilt source from `main` using the static settings.

- **No deploy branch:** push the workflow to `main` and inspect Actions. A local commit alone does not start a hosted run.
- **Push returns 403 or branch-rule rejection:** ensure Actions is enabled and repository/organization rules allow the job's `contents: write` token to update `deploy`. This workflow does not need a PAT or GitHub Pages permissions.
- **Old build command still runs:** check the existing Pages project's saved production branch and build settings, and redeploy the latest `deploy` commit.
- **Pages returns 404:** verify output directory `.` and check that `index.html` is at the root of `deploy`.
- **No Pages deployment after a new deploy commit:** check the Cloudflare GitHub app's repository access, automatic production deployments, and build watch paths. If needed, manually deploy the latest `deploy` commit from the Pages dashboard.
- **No changes published:** this is expected if the generated site tree is identical to the current `deploy` tree.

Official references: [GitHub workflow triggers](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow), [ruby/setup-ruby](https://github.com/ruby/setup-ruby), [Cloudflare static HTML](https://developers.cloudflare.com/pages/framework-guides/deploy-anything/), [Cloudflare branch controls](https://developers.cloudflare.com/pages/configuration/branch-build-controls/).
