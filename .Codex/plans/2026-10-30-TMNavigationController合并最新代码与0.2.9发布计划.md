# TMNavigationController 合并最新代码与 0.2.9 发布计划

状态：用户已确认改发普通稳定版 `0.2.9`，并已授权拉取合并、推送 master 和发布。直接执行，不重复询问。

## 原因与范围

- 远端 master 已含本次 SDK 兼容修复 `2e2af58`。
- 远端 develop 新增 `1c6458f`，以旧 `0.2.2` 基线直接升为 `0.2.8`，同时增加 Xcode 用户配置；远端 `0.2.8` 标签指向该提交。
- Specs 已于北京时间 2026-10-30 13:23:01 发布 `0.2.8`，却指向 `youxingge/TMNavigationController`；该上游仓库未发现 `0.2.8` 标签。
- 保留现有 `0.2.8` 标签和 Specs，不覆盖已发布版本；将 SDK 兼容修复和最新 develop 改动合并至 master，发布 `0.2.9`，source 指向 BaiTu fork 的正确标签。
- 不修改消费方依赖，不发布其他组件；`.Codex/plans` 文档继续保留本地。

## 执行步骤

- [x] 拉取 origin，核实 master/develop/tag/Specs 当前状态。
- [ ] 解决 Xcode Scheme 用户配置的 add/add 冲突：合并配置项，相同配置采用最新 develop 值，保留 master 其他项目；不修改生产代码。
- [ ] 按团队提交流程完成 merge commit，确认生产源码与已验证修复提交一致。
- [ ] podspec 升级为 `0.2.9`；验证版本/source/tag、Ruby 语法、CocoaPods lint 和必要构建，复用未变化源码的已通过测试证据。
- [ ] 提交版本，推送 master，创建并推送 `0.2.9` 标签，沿用 `pod publish baitu-specs TMNavigationController.podspec --to-github --debug` 发布。
- [ ] 核验远端 master/tag/Specs；隔离安装无版本依赖示例，确认选择 `0.2.9` 并完成构建。
- [ ] 在本目录保存中文完成总结，注明真实旧 SDK/Jenkins 未重跑的边界。

## 网络与权限

- 仅对本次 Git/发布进程清除失效代理，沿用已有 GitHub credential helper，不更改全局网络或凭据配置。
- Specs 当前账号具有 WRITE，清除本次代理后 dry-run 成功；本次正式推送仍须按实际结果判断。
