# TMNavigationController 普通 0.2.8 修复合并与发布进展总结

日期：2026-10-30。当前状态：修复及本地 master 合并完成，远端发布尚未完成。

## 已完成改动

- `TMNavigationBarView.m` 中 iOS 27.1 新类型的声明、初始化、布局调用、实现均增加 SDK 编译期保护；继续保留运行时版本判断，未改布局算法。
- 现有 XCTest 的新类型分支增加同样保护。
- podspec 升级为普通稳定版 `0.2.8`，source tag 为 `0.2.8`。
- 提交：`2e2af58`，`fix: 🐛 隔离新 SDK 专属 API 并升级 0.2.8`。
- 已从 `codex/fix-sdk-compat-0.2.8` fast-forward 合并至本地 `master`；只提交本次 3 个源码与版本文件，计划总结保留本地。
- 未修改或发布 BTUserContact，也未修改其他组件依赖。

## 验证结果

- 隔离 clang 验证：预包含 UIKit 后把 SDK 上限设为 26.0，并 poison iOS 27.1 新类型；修复前导航栏编译报 9 处错误，修复后 4 个生产 `.m` 文件全部通过。
- 正常 iOS 27.1 SDK 的 4 个生产 `.m` 文件全部通过编译检查，最低目标 iOS 15.0。
- 现有 XCTest 源码在屏蔽新类型的隔离编译检查中也已通过。
- `xcb` Release 真机目标构建通过；现有 7 项废弃 API 警告未扩展处理。
- `xcb pod lib lint TMNavigationController.podspec --allow-warnings --platforms=ios` 通过；包含现有废弃 API 与 homepage URL 校验警告。
- 现有 5 个布局 XCTest 在 iOS 27.0 模拟器中 5/5 通过。最初 Example 因缺少 Scene 生命周期不能启动；仅修改 `/tmp` 下已构建测试宿主的 Info.plist 后使用 `test-without-building` 通过，未改仓库配置。
- 禁止关键词、Ruby 语法、podspec 版本/source/tag、改动格式化、非阻断注释诊断、提交 hook 均通过；独立审查未发现可确认缺陷。
- 本机未执行真实旧 SDK 或 Jenkins 的 BTUserContact 原打包流水线，上述隔离验证不能替代该验证。

验证目录：`/tmp/tmnavigation-0.2.8-validation`。测试结果：`scene-host-layout-tests.xcresult`。

## 远端发布进展

- 预检时源码远端 `master` 仍为 `397f6d4`；未发现 `0.2.8` 标签，远端 Specs 对应版本返回 404。
- 当前 `gh` 账号为 `youxingge`，源码仓库推送预检返回 HTTP 403：`Permission to BaiTu-iOS/TMNavigationController.git denied to youxingge`。
- 默认 Git 认证的首次预检遇到代理 SSL 连接错误，继续核对现有合法认证方式。
- 尚未创建或推送 `0.2.8` 标签，尚未推送源码或发布 Specs；待写权限恢复后继续推送、发布及远端无版本依赖解析验证。
- 已请求用户为当前账号开通源码仓库和 Specs 写权限，或在本机切换已有权限的账号；不要求用户在聊天中提供 Token。
