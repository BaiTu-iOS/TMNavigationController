# TMNavigationController 普通 0.2.8 发布计划

状态：用户已确认发布普通稳定版 `0.2.8`，本计划替代此前 BAITU 方案，直接分步执行。

> 后续变更：远端另行创建的 `0.2.8` 标签指向 `develop` 旧基线，用户已确认保留已有标签并改发 `0.2.9`。后续执行见《2026-10-30-TMNavigationController合并最新代码与0.2.9发布计划.md》。

## 目标与范围

- 仅修复旧 SDK 无法识别 iOS 27.1 类型的编译错误，保留新 SDK 的折叠屏适配及原有布局算法。
- 修改 `TMNavigationController/Classes/TMNavigationBarView.m`、`Example/Tests/Tests.m`、`TMNavigationController.podspec`。
- 发布稳定版 `0.2.8` 到现有源码仓库和 BaiTu Specs；不修改或发布 BTUserContact。
- 用户的“发布普通 0.2.8”已授权必要提交、源码推送、标签及 Specs 发布，无需重复询问。

## 步骤

- [x] 用隔离编译验证复现新类型未屏蔽的问题，再为声明、初始化、布局调用、实现和测试添加 `__IPHONE_OS_VERSION_MAX_ALLOWED >= 270100` 保护。
- [x] 保存后按团队规则格式化改动行，执行禁止关键词检查及非阻断注释诊断。
- [x] 验证正常 SDK 和缺少新 API 的编译分支；运行现有 5 个布局测试及 Release 真机目标构建。缺少新 API 的模拟验证不冒充旧 SDK 或 Jenkins 实测。
- [x] podspec 升级为 `0.2.8`，验证语法、Specs 和远端版本未占用，独立审查最终 diff。
- [x] 按 `wk:git-commit` 显式提交本次源码和版本文件；按用户后续明确要求合并到本地 `master`。
- [ ] 推送源码及 `0.2.8` 标签，沿用 YYText 的源码包发布命令发布到 `baitu-specs`。
- [ ] 核验远端源码、标签、Specs，隔离安装一个无版本依赖示例，确认解析为 `0.2.8` 并构建。
- [ ] 将实际发布结果和验证边界保存到本目录的中文完成总结。

## 执行记录

- 起始提交：`397f6d4`；起始工作区仅有本次计划文档，无源码改动。
- 决策：复用当前 checkout，创建 `codex/` 修复分支；本次没有需要独立工作树的用户源码修改。
- 版本调整依据：用户明确要求普通 `0.2.8`，消费方无版本依赖可选择稳定版，无需改消费方。
- 已提交 `2e2af58` 并 fast-forward 合并到本地 `master`；独立审查无可确认缺陷。
- Example 缺少 Scene 生命周期，最初的 iOS 27 测试启动失败；仅在 `/tmp` 中的已构建测试宿主 Info.plist 增加 Scene 配置，随后 5/5 通过，未修改仓库中的 Example 配置。
- 远端预检：`gh` 当前账号 `youxingge` 对源码仓库推送返回 403，正在核对现有认证；尚未发布，不将本地合并描述为远端完成。
