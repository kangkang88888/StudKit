# StudKit 架构设计文档

## 概述

StudKit是一款macOS系统级工具，通过Accessibility API实现全局文本选中检测，并在选中文本附近显示悬浮复制菜单。本文档详细说明系统的架构设计、组件交互和实现细节。

## 系统架构

### 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        macOS System                          │
├─────────────────────────────────────────────────────────────┤
│                    Accessibility API                         │
│              (AXUIElement, AXObserver)                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                        StudKit App                           │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ AppDelegate   │→ │ Accessibility    │  │ Status Bar   │ │
│  │               │  │ Manager          │  │ Menu         │ │
│  └───────┬───────┘  └──────────────────┘  └──────────────┘ │
│          │                                                   │
│          ↓                                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │          TextSelectionMonitor                         │  │
│  │  - Mouse event monitoring                             │  │
│  │  - Text selection detection                           │  │
│  │  - Selection bounds calculation                       │  │
│  └─────────────────────┬─────────────────────────────────┘  │
│                        │                                     │
│                        ↓                                     │
│  ┌───────────────────────────────────────────────────────┐  │
│  │       FloatingMenuController                          │  │
│  │  - Position calculation                               │  │
│  │  - Menu lifecycle management                          │  │
│  │  - Auto-hide timer                                    │  │
│  └─────────────────────┬─────────────────────────────────┘  │
│                        │                                     │
│                        ↓                                     │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         FloatingMenuWindow                            │  │
│  │  - UI rendering (80x36px)                             │  │
│  │  - Animation (fade in/out)                            │  │
│  │  - Copy button interaction                            │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                   System Pasteboard                          │
└─────────────────────────────────────────────────────────────┘
```

## 核心组件

### 1. AppDelegate

**职责**:
- 应用生命周期管理
- 初始化各个管理器
- 配置状态栏菜单
- 处理应用启动和退出

**关键方法**:
```swift
func applicationDidFinishLaunching(_ notification: Notification)
- 隐藏Dock图标
- 创建状态栏菜单
- 初始化管理器
- 检查和请求权限

func startMonitoring()
- 启动文本选中监控

func pauseMonitoring()
- 暂停监控并隐藏菜单

func quitApp()
- 清理资源并退出应用
```

### 2. AccessibilityManager

**职责**:
- 管理Accessibility API权限
- 检测权限状态
- 引导用户授权
- 监控权限变化

**核心功能**:

#### 权限检查
```swift
func checkPermissions() -> Bool
```
使用`AXIsProcessTrustedWithOptions`检查是否已授予辅助功能权限。

#### 权限请求
```swift
func requestPermissions()
```
- 调用系统权限请求对话框
- 显示自定义引导提示
- 提供一键跳转系统设置

#### 权限监控
```swift
func startPermissionMonitoring(onPermissionGranted: @escaping () -> Void)
```
定时检查权限状态，授权后执行回调。

### 3. TextSelectionMonitor

**职责**:
- 监听全局鼠标事件
- 检测文本选中状态
- 读取选中的文本内容
- 计算选中文本的屏幕坐标
- 过滤隐私文本区域

**工作流程**:

```
鼠标按下选择文本
    ↓
鼠标松开 (触发mouseUp事件)
    ↓
延迟50ms等待选中完成
    ↓
handlePotentialTextSelection()
    ↓
getSelectedText() - 读取文本内容
    ├→ 通过AXSelectedTextAttribute读取
    ├→ 检查是否为密码框 (isSecureTextField)
    └→ 失败则降级到剪贴板
    ↓
getSelectionBounds() - 计算位置
    ├→ 获取选中范围 (AXSelectedTextRangeAttribute)
    ├→ 获取范围边界 (AXBoundsForRangeParameterizedAttribute)
    └→ 转换为屏幕坐标
    ↓
调用FloatingMenuController.showMenu()
```

**关键方法**:

#### 文本读取
```swift
private func getSelectedText() -> String?
```
- 超时控制: 100ms
- 优先级: Accessibility API > 系统剪贴板
- 隐私过滤: 跳过密码框和敏感文本

#### 边界计算
```swift
private func getSelectionBounds() -> NSRect?
```
- 读取选中范围的屏幕坐标
- 处理坐标系转换 (Cocoa坐标系 → 屏幕坐标系)
- 降级处理: 元素位置和尺寸

#### 隐私检测
```swift
private func isSecureTextField(_ element: AXUIElement) -> Bool
```
检查元素角色是否为`AXSecureTextField`。

### 4. FloatingMenuController

**职责**:
- 管理悬浮菜单的显示和隐藏
- 计算菜单最佳位置
- 处理复制操作
- 管理自动隐藏定时器

**位置计算算法**:

```swift
func calculateMenuPosition(for selectionBounds: NSRect) -> NSPoint
```

**优先级规则**:
1. 默认: 选中文本右上角 (x: maxX + 5, y: maxY - 2)
2. 超出右边界: 左上角 (x: minX - width - 5)
3. 超出上边界: 右下角 (y: minY - height - 5)
4. 超出左/下边界: 居中对齐
5. 最终钳位到屏幕可视区域

**边界适配逻辑**:

```
检查右边界溢出
    ↓ Yes
移动到选中文本左侧
    ↓
检查上边界溢出
    ↓ Yes
移动到选中文本下方
    ↓
检查左/下边界溢出
    ↓ Yes
居中对齐
    ↓
钳位到屏幕内
```

**自动隐藏机制**:
- 触发条件: 显示后5秒无交互
- 实现: `Timer.scheduledTimer(withTimeInterval: 5.0)`
- 取消: 用户交互时重置定时器

### 5. FloatingMenuWindow

**职责**:
- 渲染悬浮菜单UI
- 实现淡入淡出动画
- 处理用户交互
- 监听点击外部事件

**UI规格**:
- 尺寸: 80x36px
- 圆角: 8px
- 背景: 半透明白色/黑色 (根据系统主题)
  - 亮色模式: rgba(255,255,255,0.9)
  - 暗色模式: rgba(40,40,40,0.9)
- 字体: SF Pro 13pt
- 层级: NSStatusWindowLevel + 1

**交互状态**:

1. **常态**: 透明背景
2. **Hover**: 背景加深
   - 亮色: rgba(240,240,240,0.8)
   - 暗色: rgba(60,60,60,0.8)
3. **按下**: 背景进一步加深
4. **点击后**: 延迟100ms淡出

**动画实现**:

```swift
// 淡入
NSAnimationContext.runAnimationGroup({ context in
    context.duration = 0.1
    self.animator().alphaValue = 1.0
})

// 淡出
NSAnimationContext.runAnimationGroup({ context in
    context.duration = 0.1
    self.animator().alphaValue = 0.0
}, completionHandler: {
    self.orderOut(nil)
})
```

**点击外部检测**:
```swift
private func setupClickOutsideMonitor()
```
使用`NSEvent.addGlobalMonitorForEvents`监听全局鼠标点击，检测点击位置是否在菜单范围外。

## 数据流

### 文本选中到复制的完整流程

```
1. 用户选中文本
   ↓
2. NSEvent.mouseUp触发
   ↓
3. TextSelectionMonitor.handlePotentialTextSelection()
   ↓
4. 读取选中文本 (Accessibility API)
   ├→ 成功: 继续
   └→ 失败: 尝试剪贴板或放弃
   ↓
5. 计算选中区域边界
   ├→ 成功: 继续
   └→ 失败: 放弃显示菜单
   ↓
6. FloatingMenuController.showMenu(at:with:)
   ↓
7. 计算菜单最佳位置
   ├→ 检查屏幕边界
   └→ 调整位置避免溢出
   ↓
8. FloatingMenuWindow.show()
   ├→ 淡入动画 (0.1s)
   └→ 设置5秒自动隐藏定时器
   ↓
9. 用户点击"Copy"按钮
   ↓
10. FloatingMenuController.handleCopy()
    ├→ NSPasteboard.general.setString()
    └→ 延迟100ms隐藏菜单
    ↓
11. FloatingMenuWindow.hide()
    └→ 淡出动画 (0.1s)
```

## 性能优化

### 事件节流

**问题**: 频繁的鼠标移动和选中操作会导致高CPU占用。

**解决方案**:
1. 仅监听`mouseUp`事件，不监听`mouseDragged`
2. 延迟50ms处理选中检测，确保选中完成
3. 文本读取超时限制100ms
4. 10秒内重复选中同一文本直接复用缓存

### 内存管理

**关键点**:
1. 使用`weak self`避免循环引用
2. 及时移除事件监听器
3. 窗口隐藏时释放不必要的资源
4. 限制文本缓存大小和时间

### 响应时间优化

**目标**: 鼠标松开到菜单显示 ≤ 150ms

**优化措施**:
- Accessibility API调用异步化
- 位置计算缓存屏幕参数
- 预创建菜单窗口复用
- 动画时长控制在0.1s

## 兼容性处理

### Electron应用

**问题**: Electron应用使用`AXWebArea`封装DOM元素。

**解决方案**:
- 深度遍历Accessibility控件树
- 特殊处理`AXWebArea`子元素
- 降级到剪贴板读取

### 浏览器网页

**问题**: 网页DOM元素结构复杂，坐标计算可能不准确。

**解决方案**:
- 过滤非文本元素（图片、视频等）
- 仅处理文本标签（p, div, input等）
- 使用选中范围参数化属性获取精确边界

### 代码编辑器

**问题**: 代码行高不同，垂直偏移计算可能偏差。

**解决方案**:
- 使用实际选中范围的边界而非元素边界
- 支持等宽字体的坐标计算
- 适配Xcode和VS Code的特殊控件

## 安全和隐私

### 隐私保护

1. **密码框过滤**: 检测`AXSecureTextField`角色
2. **敏感文本标记**: 检查`AXPrivacySensitive`属性
3. **用户控制**: 提供暂停/恢复功能
4. **最小权限**: 仅请求必要的辅助功能权限

### 数据安全

1. **本地处理**: 所有文本处理在本地完成
2. **无网络传输**: 不上传任何用户数据
3. **内存清理**: 及时清除文本缓存
4. **系统粘贴板**: 使用系统标准API

## 错误处理

### 权限未授予

- 显示友好提示框
- 提供一键跳转设置
- 降级到手动模式（未实现）

### 文本读取失败

- 静默跳过，不显示菜单
- 避免打断用户工作流
- 尝试降级到剪贴板

### 菜单定位失败

- 使用默认位置
- 确保不超出屏幕边界
- 最坏情况: 不显示菜单

### 复制功能失败

- 按钮置灰提示用户
- Hover显示错误信息
- 不中断应用运行

## 未来优化方向

1. **多显示器支持**: 优化跨屏幕的菜单定位
2. **自定义快捷键**: 允许用户配置唤起菜单的快捷键
3. **历史记录**: 保存最近复制的文本历史
4. **更多功能**: 搜索、翻译、格式化等
5. **插件系统**: 允许第三方扩展功能
6. **性能监控**: 内置性能监控和优化建议
7. **配置界面**: 提供图形化配置界面

## 参考资料

- [Accessibility API Reference](https://developer.apple.com/documentation/applicationservices/accessibility)
- [NSEvent Monitoring](https://developer.apple.com/documentation/appkit/nsevent)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [NSWindow Styling](https://developer.apple.com/documentation/appkit/nswindow)
