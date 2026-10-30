# TMNavigationController 兼容修复与 BAITU 发布计划

> 已被用户确认的《2026-10-30-TMNavigationController普通0.2.8发布计划.md》替代；不执行本文的 BAITU 发布和 BTUserContact 修改。

日期：2026-10-30。状态：待用户确认执行，尚未修改源码、提交或发布。

**目标**：修复旧 SDK 编译 `TMNavigationBarView.m` 时的新类型错误，参照 YYText 发布 `0.2.8.BAITU` 源码包，让已知失败方 BTUserContact 使用修复版。

**方案**：为 iOS 27.1 专属声明、实现和调用增加 SDK 编译期保护，并保留运行时 `@available`；旧 SDK 沿用现有安全区和按钮布局。`.BAITU` 是 CocoaPods 预发布版本，需要消费方显式允许，不能仅发布后就宣称无版本依赖会自动选中。

**技术栈**：Objective-C、XCTest、CocoaPods、cocoapods-publish、GitHub BaiTu Specs。

## 当前证据

- 当前分支 `master`，HEAD `397f6d4`，工作区源码干净，podspec 和远端最新稳定标签均为 `0.2.7`。
- `TMNavigationController/Classes/TMNavigationBarView.m:15、28、149、174、180` 直接使用 iOS 27.1 类型，缺少 SDK 编译期隔离；与 Jenkins 日志吻合。
- 本机 Xcode 27.1 / iOS SDK 27.1 对当前组件执行 Release、generic iOS、关闭签名构建成功；本机未发现可直接使用的旧版 Xcode，不代表 Jenkins 已验证。
- `Example/Tests/Tests.m:114` 同样包含新类型，测试代码也需要保护。
- `/Users/wupengwei/Desktop/sourceCode/BTUserContact/BTUserContact.podspec:70` 当前为无版本依赖。
- 当前 CocoaPods 1.16.2 的 Resolver 排除无版本依赖下的 `.BAITU`，当前 publish 2.9.9 仅对 `.swift` 特判；不得依赖不存在的 `.BAITU` 自动替换规则。
- YYText 发布参考：`/Users/wupengwei/Desktop/sourceCode/YYText/.Codex/plans/2026-10-22-YYText版本升级发布完成总结.md`。
- Specs：`https://github.com/BaiTu-iOS/baitu-specs`，本地目录 `/Users/wupengwei/.cocoapods/repos/baitu-specs` 已落后于远端，发布前需要更新。

## 约束与审查重点

- 保持 iOS 15.0 最低版本、现有公开 API 和新 SDK 下的 iOS 27.1 适配。
- 编译期条件采用 `#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 270100`，覆盖所有专属类型的声明、实现、调用和测试。
- 只修改与编译兼容和选版直接相关的内容，格式化限定改动范围；按团队规则执行禁止关键词及非阻断注释诊断。
- 发布前重新核实工作区、远端标签和 Specs，禁止覆盖已有版本或标签。
- 本次显式消费方范围为 BTUserContact；其他无版本消费方不会因此自动改用 `.BAITU`，后续需在相应依赖声明或构建入口显式允许该版本。

## 分步执行

### 一、修复并验证 SDK 兼容

涉及：`TMNavigationController/Classes/TMNavigationBarView.m`、`Example/Tests/Tests.m`。

- [ ] 对缺失新 API 的 SDK 建立编译失败证据；若本机无旧 SDK，使用隔离的头文件屏蔽方式验证，并明确它不能替代 Jenkins 旧 SDK 实测。
- [ ] 给新 API 的声明、初始化、两处布局调用、辅助方法实现及测试分支增加编译期保护；增加说明运行时判断无法解决旧 SDK 编译问题的简短注释。
- [ ] 自动格式化本次源码改动，执行禁止关键词检查、注释诊断和 `git diff --check`。
- [ ] 用 `xcb` 构建真机 Release 目标，运行已有 5 个布局 XCTest；覆盖正常 SDK 分支及无新 API 分支，确认没有修改布局算法。

### 二、准备并发布 0.2.8.BAITU

涉及：`TMNavigationController.podspec`、源码仓库标签、BaiTu Specs。

- [ ] 将 `s.version` 设为 `0.2.8.BAITU`，source 保持 `https://github.com/BaiTu-iOS/TMNavigationController.git`，tag 与版本一致。
- [ ] 执行 Ruby 语法和 podspec 验证，审查差异；按 `wk:git-commit` 显式暂存本次文件并提交。
- [ ] 确认源码提交可从远端获取，再创建和推送 `0.2.8.BAITU` 标签；本任务的“发布”授权包括必要源码、标签和 Specs 推送，不推送其他仓库无关提交。
- [ ] 复核当前发布插件参数后，沿用 YYText 命令：`pod publish baitu-specs TMNavigationController.podspec --to-github --debug`。不跳过构建验证，不输出凭据。
- [ ] 核验远端 tag 指向、tag 下源码与 podspec、Specs 中的版本与 source tag；从远端安装修复包并完成组件构建。

### 三、让 BTUserContact 消费修复版并收口

涉及：`/Users/wupengwei/Desktop/sourceCode/BTUserContact/BTUserContact.podspec`。

- [ ] 先检查该仓库当前状态，保留已有用户改动；把 TMNavigationController 依赖显式固定为 `0.2.8.BAITU`，注明旧 SDK 编译兼容原因。
- [ ] 在隔离安装目录解析 BTUserContact，确认实际下载版本为 `0.2.8.BAITU`；对其依赖执行构建，具备原流水线时再重跑原打包命令。
- [ ] BTUserContact 的依赖修改默认保留本地，不擅自发布 BTUserContact 或推送其其他工作。
- [ ] 将验证结果、提交、标签、Specs 地址、消费方实际解析版本及未验证事项写入本目录中文完成总结。

## 执行确认

按用户 AGENTS.md 要求，计划先落盘，再询问是否按上述步骤执行。确认前只进行只读调查及计划文档保存。
