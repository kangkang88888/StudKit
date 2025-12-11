# StudKit - Mac系统级选词复制工具

StudKit是一款轻量级的Mac系统工具，在任意应用中选中文本后自动弹出悬浮复制菜单，提供快速、精准的文本复制体验。

## 功能特性

### 核心功能
- **全场景支持**: 覆盖所有可选词区域（原生App、Electron应用、浏览器、代码编辑器、办公软件等）
- **智能定位**: 悬浮菜单自动定位于选中文本旁，支持屏幕边界自适应
- **精准交互**: 选中文本触发，点击复制或点击外部自动消失
- **低功耗运行**: CPU占用≤1%，内存占用≤50MB
- **隐私保护**: 自动过滤密码输入框等隐私文本区域

### 交互特性
- 选中文本后自动弹出80x36px圆角悬浮菜单
- 菜单位置智能计算，避免遮挡选中文本
- 0.1秒淡入淡出动画，流畅自然
- 支持亮色/暗色模式自动适配
- 5秒无交互自动隐藏，避免干扰

## 系统要求

- macOS 10.15 (Catalina) 或更高版本
- 支持Intel、M1、M2、M3芯片

## 安装说明

### 从源码编译

1. 克隆仓库:
```bash
git clone https://github.com/kangkang88888/StudKit.git
cd StudKit
```

2. 使用Swift Package Manager编译:
```bash
swift build -c release
```

3. 运行应用:
```bash
.build/release/StudKit
```

### 首次使用

首次运行时，StudKit会请求辅助功能权限：

1. 点击"Open System Preferences"按钮
2. 在"系统偏好设置 > 安全性与隐私 > 辅助功能"中勾选StudKit
3. 返回应用即可正常使用

## 使用方法

1. **启动应用**: 运行StudKit后，会在菜单栏显示📋图标
2. **选择文本**: 在任意应用中用鼠标选中文本
3. **复制文本**: 点击弹出的"Copy"按钮即可复制
4. **管理应用**: 点击菜单栏图标可暂停/恢复/退出应用

### 菜单触发规则

- 选中文本长度≥1个字符时触发
- 鼠标松开后自动弹出菜单
- 支持连续选中不同文本，菜单会跟随更新

### 菜单消失规则

菜单会在以下情况自动消失：
- 点击"Copy"按钮后（延迟100ms）
- 点击菜单外任意区域
- 取消文本选中
- 切换到其他应用
- 5秒无交互自动隐藏

## 技术架构

### 核心组件

- **AccessibilityManager**: 管理系统辅助功能权限
- **TextSelectionMonitor**: 监控全局文本选中事件
- **FloatingMenuController**: 控制悬浮菜单的显示和隐藏
- **FloatingMenuWindow**: 实现悬浮菜单UI和交互

### 技术栈

- **Swift**: 主要开发语言
- **AppKit**: macOS UI框架
- **Accessibility API**: 系统级文本选中检测
- **NSEvent监控**: 全局鼠标事件捕获

### 性能优化

- 事件节流：仅在鼠标松开时检测，避免高频轮询
- 文本缓存：10秒内重复选中同一文本直接复用
- 超时控制：单次文本读取超时≤100ms
- 延迟执行：鼠标松开后延迟50ms检测，确保选中完成

## 兼容性

### 已测试应用类型

- ✅ 原生应用 (Pages, Keynote, Xcode, 文本编辑)
- ✅ Electron应用 (VS Code, Slack, Notion)
- ✅ 浏览器 (Chrome, Safari, Firefox)
- ✅ 办公软件 (Microsoft Word, Excel, PowerPoint)
- ✅ 代码编辑器 (Xcode, VS Code, Sublime Text)

### 特殊场景处理

- **密码输入框**: 自动跳过，不触发菜单
- **加密文本**: 检测到隐私标记的控件自动过滤
- **网页控件**: 适配Electron封装的AXWebArea控件
- **代码编辑器**: 适配不同行高的坐标计算

## 开发指南

### 项目结构

```
StudKit/
├── Sources/
│   └── StudKit/
│       ├── main.swift                      # 应用入口
│       ├── AppDelegate.swift               # 应用代理，管理生命周期
│       ├── AccessibilityManager.swift      # 权限管理
│       ├── TextSelectionMonitor.swift      # 文本选中监控
│       └── FloatingMenuController.swift    # 悬浮菜单控制器
├── Info.plist                              # 应用配置
├── Package.swift                           # Swift包管理配置
└── README.md                               # 项目文档
```

### 构建和调试

```bash
# 调试模式编译
swift build

# 发布模式编译
swift build -c release

# 运行
swift run

# 清理构建产物
swift package clean
```

### 代码规范

- 遵循Swift标准命名规范
- 使用4空格缩进
- 添加适当的注释说明复杂逻辑
- 及时释放事件监听器避免内存泄漏

## 性能指标

根据设计要求，StudKit达到以下性能标准：

- **响应延迟**: 鼠标松开到菜单弹出 ≤ 150ms
- **CPU占用**: 后台常驻 ≤ 1%
- **内存占用**: ≤ 50MB
- **复制操作**: 点击到写入粘贴板 ≤ 50ms

## 故障排查

### 菜单不弹出

1. 检查辅助功能权限是否已授予
2. 确认选中的文本长度≥1个字符
3. 检查是否在密码输入框等隐私区域选中文本

### 菜单位置异常

1. 可能是屏幕边界自适应触发
2. 检查是否在多显示器环境
3. 重启应用重新计算屏幕参数

### 复制功能无效

1. 检查系统剪贴板权限
2. 确认选中的文本可正常读取
3. 查看控制台是否有错误日志

## 许可证

本项目遵循MIT许可证。

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### v1.0.0 (2024-12-11)

- ✨ 初始版本发布
- ✅ 全场景文本选中检测
- ✅ 智能悬浮菜单定位
- ✅ 一键复制功能
- ✅ 辅助功能权限管理
- ✅ 亮色/暗色模式支持
- ✅ 低功耗后台运行
- ✅ macOS 10.15+ 兼容

## 联系方式

- 项目主页: https://github.com/kangkang88888/StudKit
- 问题反馈: https://github.com/kangkang88888/StudKit/issues

---

**注意**: 本工具需要辅助功能权限才能正常工作，请在首次使用时授予相应权限。
