# TMNavigationController 发布排查与计划总结

日期：2026-10-30。此次完成排查与计划保存，尚未实施修复或发布。

- 已确认旧 SDK 编译失败源于直接引用 iOS 27.1 类型，只有 `@available` 不能隔离编译期类型检查。
- 已核对 YYText 的 `.BAITU` 源码包发布方式、BaiTu Specs 和当前发布插件。
- 当前 TMNavigationController 为 `0.2.7`；拟发布 `0.2.8.BAITU`，避免复用已有版本标签。
- 已验证普通无版本依赖不会自动选中 `.BAITU`，计划让已知失败方 BTUserContact 显式依赖修复版本。
- 本机当前源码真机目标 Release 构建通过，退出码 0，出现 7 项现有废弃 API 警告；原始日志位于 `/var/folders/kk/v2yqmk9d4672mnp21r7qxrxr0000gn/T/wk-xcodebuild/xcb-20261030-120029-95710.log`。
- 上述构建使用 Xcode 27.1 / iOS SDK 27.1，不代表 Jenkins 旧 SDK 或 BTUserContact 打包已通过；本轮未运行 XCTest。
- 本轮仅新增本目录计划与总结文档，未修改源码、podspec、BTUserContact 或依赖仓库；未执行提交、标签创建和推送。

后续步骤见同目录《2026-10-30-TMNavigationController兼容修复与BAITU发布计划.md》，等待用户确认是否分步执行。
