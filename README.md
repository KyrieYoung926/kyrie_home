# Xun Kyrie Yang — Academic Homepage

Personal academic website built with [al-folio](https://github.com/alshedivat/al-folio) and Jekyll.

- Website: **https://me.kyrielab.com**
- CatchItMan: **https://play.kyrielab.com**
- Source: **https://github.com/KyrieYoung926/kyrie_home**

This repository contains the current homepage, five publications, four research projects, research images, and downloadable PDF CV. Theme layouts and assets are supplied by the pinned `al_folio_core` gem.

## Build and deployment

```text
push main → GitHub Actions builds Jekyll → deploy branch → Cloudflare Pages
```

GitHub Actions runs `.github/workflows/deploy.yml` on every push to `main` and supports a manual run from the Actions tab. It installs the locked Ruby/Bundler dependencies, builds with explicit UTF-8 encoding, tests the branch publisher, and publishes **the contents of `_site/` at the root of `deploy`**. Only successful builds update that branch; its commit history is preserved.

Website content and `_config.yml` remain on `main`. Do not edit generated files on `deploy`.

### Manual GitHub setup

1. Enable GitHub Actions for this repository and allow the actions used by the workflow (`actions/checkout`, `actions/setup-node`, `ruby/setup-ruby`).
2. Push this commit to `main`. Check **Actions → Build site and publish deploy branch**; the first successful run creates `deploy` automatically. You can also use **Run workflow** on `main`.
3. The workflow requests `contents: write` for its job and uses the built-in `GITHUB_TOKEN`; no personal access token or Cloudflare secret is required. Ensure any organization policies or branch rules permit the workflow to create/update `deploy`. Keep `main` as the repository's default branch.

### Manual Cloudflare Pages setup

After `deploy` exists, update the **existing** Pages project connected to this repository:

| Setting                    | Value                                                  |
| -------------------------- | ------------------------------------------------------ |
| Production branch          | `deploy`                                               |
| Framework preset           | `None`                                                 |
| Root directory             | Leave empty (repository root)                          |
| Build command              | `exit 0`                                               |
| Build output directory     | `.` (repository root, **not** `_site` or `public`)     |
| Environment variable       | `SKIP_DEPENDENCY_INSTALL=1`                            |
| Preview branch deployments | Disable previews to avoid deploying source-only `main` |

Remove the old `RUBY_VERSION` and `JEKYLL_ENV` variables from Cloudflare; Ruby runs in GitHub Actions now. Keep automatic production deployments enabled. If custom build watch paths were configured, make sure they include the generated files on `deploy` (using all paths is simplest).

Save the settings, deploy the latest `deploy` commit, and check the Pages URL and `me.kyrielab.com`. Preserve the existing custom-domain association and DNS configuration when they already point to this Pages project. If the domain still points to the old Tunnel, bind it through Pages **Custom domains** and change only the `me` record when ready.

No Cloudflare settings or DNS are changed by committing this workflow. GitHub Pages does not need to be enabled.

See [deployment details and encoding investigation](docs/DEPLOYMENT.md) for the root cause, verification commands, and troubleshooting.

## 修改内容

| 文件                       | 内容                                               |
| -------------------------- | -------------------------------------------------- |
| `_pages/about.md`          | 首页简介和研究图片                                 |
| `_bibliography/papers.bib` | 论文、链接、审稿状态；`selected={true}` 显示在首页 |
| `_projects/*.md`           | 项目介绍及链接                                     |
| `_pages/cv.md`             | 网页版 CV                                          |
| `assets/pdf/CV1101.pdf`    | 可下载的 PDF 简历                                  |
| `_data/socials.yml`        | 邮箱、简历和 Bilibili 链接                         |
| `_config.yml`              | 姓名、域名及功能设置                               |
| `docs/IMAGE_SOURCES.md`    | 项目图片来源                                       |

部分原始论文和 PDF 中的署名仍使用 Xun Yang；网站显示名为 Xun Kyrie Yang。One Motion 的原始 CV 没有完整作者名单，因此该条暂用 et al.，待完整名单补充。

## 本地预览

安装 Ruby 3.3.6 和 Node.js（部分插件用作 JavaScript 运行时），然后执行：

```bash
gem install bundler --version 4.0.6
bundle _4.0.6_ config set --local path vendor/bundle
bundle _4.0.6_ install
bundle _4.0.6_ exec jekyll serve --host 127.0.0.1 --port 4001
```

使用 UTF-8 locale（如 `LANG=C.UTF-8 LC_ALL=C.UTF-8`）进行本地预览，访问 `http://127.0.0.1:4001/`。修改内容后自动重建；修改 `_config.yml` 后需重启预览。

仅生成生产静态文件：

```bash
bash bin/build-site.sh
```

网站部署在域名根目录，保持 `_config.yml` 中的 `baseurl: ""`。

## Attribution

Theme: [al-folio](https://github.com/alshedivat/al-folio), MIT license (see `LICENSE`). Research images link to their original project websites; see `docs/IMAGE_SOURCES.md`.
