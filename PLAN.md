# 发布计划

目标：让别人访问 `https://dnf88896.github.io/voices38-pragmata/` 后可以下载 `E:\pragmata\PRAGMATA-voices38\voices38-pragmata.iso`。

## 约束

- ISO 大小是 36,344,594,432 bytes，约 33.85 GiB。
- GitHub 仓库和 GitHub Pages 不适合直接存放这个单文件。
- GitHub Release 可以托管下载附件，但单个附件需要小于 2 GiB，因此需要分卷。

## 执行步骤

1. 在 E 盘准备 Pages 仓库目录：`E:\pragmata\PRAGMATA-voices38\voices38-pragmata-pages`。
2. 运行 `scripts\split-iso.ps1`，生成 `release-parts\voices38-pragmata.iso.part001` 等分卷和 `SHA256SUMS.txt`。
3. 创建 GitHub 新仓库：`dnf88896/voices38-pragmata`。
4. 推送这个目录中的网页文件到 `main` 分支。
5. 开启 GitHub Pages，来源为 `main` 分支根目录。
6. 创建 `v1.0.0` Release，上传所有分卷和 `SHA256SUMS.txt`。
7. 访问 `https://dnf88896.github.io/voices38-pragmata/`，确认页面能打开并跳转到 Release 下载页。

## 需要确认

- 如果仓库名不要叫 `voices38-pragmata`，需要在发布前把 `index.html` 和脚本里的仓库名一起改掉。

