# Xun Kyrie Yang — Academic Homepage

Personal academic website built with [al-folio](https://github.com/alshedivat/al-folio) and Jekyll.

- Website: **https://me.kyrielab.com**
- CatchItMan: **https://play.kyrielab.com**
- Source: **https://github.com/KyrieYoung926/kyrie_home**

This repository contains the current homepage, five publications, four research projects, research images, and downloadable PDF CV. Theme layouts and assets are supplied by the pinned `al_folio_core` gem.

## 在 Cloudflare Pages 启用托管

在 **Workers & Pages → Create application → Pages → Import an existing Git repository** 选择本仓库，填写：

| 配置                   | 值                                 |
| ---------------------- | ---------------------------------- |
| Production branch      | `main`                             |
| Framework preset       | `None`（使用下面的自定义构建命令） |
| Root directory         | 留空，使用仓库根目录               |
| Build command          | `bash bin/build-cloudflare.sh`     |
| Build output directory | `_site`                            |
| Build system           | 当前 v3 构建镜像                   |

在 Production 和 Preview 的环境变量中均添加：

| 环境变量                  | 值           |
| ------------------------- | ------------ |
| `RUBY_VERSION`            | `3.3.6`      |
| `JEKYLL_ENV`              | `production` |
| `SKIP_DEPENDENCY_INSTALL` | `1`          |

`.ruby-version` 也固定了 Ruby 版本。构建脚本会安装锁定的 Bundler 4.0.6、安装 Gemfile.lock 中的依赖，再生成 `_site/`。`SKIP_DEPENDENCY_INSTALL` 让脚本统一处理依赖安装。无需添加部署 token，无需 GitHub Pages，也无需本地电脑持续在线。

首次构建成功后，先检查 Cloudflare 分配的 `*.pages.dev` 地址，再在该 Pages 项目的 **Custom domains** 中添加 `me.kyrielab.com`。

当前域名仍可能指向原 Cloudflare Tunnel：绑定 Pages 时，将 `me` 的 CNAME 从 Tunnel 目标切换到 Cloudflare 为本 Pages 项目提供的目标。按控制台提示处理同名 DNS 记录；不要提前改动其他子域名。确认 Pages 自定义域名和 HTTPS 正常后，才停用旧的 `me.kyrielab.com` Tunnel 路由。本仓库迁移本身不修改 DNS 或现有线上服务。

完成 Git 集成后，后续推送到 `main` 会由 Cloudflare 自动构建发布。

官方文档：[Jekyll 部署](https://developers.cloudflare.com/pages/framework-guides/deploy-a-jekyll-site/)、[构建镜像与环境变量](https://developers.cloudflare.com/pages/configuration/build-image/)、[自定义域名](https://developers.cloudflare.com/pages/configuration/custom-domains/)。

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

访问 `http://127.0.0.1:4001/`。修改内容后自动重建；修改 `_config.yml` 后需重启预览。

仅生成生产静态文件：

```bash
JEKYLL_ENV=production bundle _4.0.6_ exec jekyll build
```

网站部署在域名根目录，保持 `_config.yml` 中的 `baseurl: ""`。

## Attribution

Theme: [al-folio](https://github.com/alshedivat/al-folio), MIT license (see `LICENSE`). Research images link to their original project websites; see `docs/IMAGE_SOURCES.md`.
