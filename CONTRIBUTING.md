# 贡献指南

感谢您对StudKit项目的关注！我们欢迎各种形式的贡献，包括但不限于：

- 报告bug
- 提出新功能建议
- 提交代码改进
- 完善文档
- 分享使用经验

## 开发环境设置

### 系统要求

- macOS 10.15 (Catalina) 或更高版本
- Xcode 12.0 或更高版本（包含Swift 5.5+）
- Git

### 克隆项目

```bash
git clone https://github.com/kangkang88888/StudKit.git
cd StudKit
```

### 构建项目

```bash
# 调试版本
swift build

# 发布版本
swift build -c release
```

### 运行项目

```bash
# 使用Swift Package Manager
swift run

# 或使用Makefile
make run
```

## 代码规范

### Swift代码风格

遵循[Swift官方API设计指南](https://swift.org/documentation/api-design-guidelines/)：

1. **命名规范**
   - 类名使用大驼峰（PascalCase）: `FloatingMenuController`
   - 方法和变量使用小驼峰（camelCase）: `showMenu()`
   - 常量使用小驼峰: `autoHideDelay`
   - 私有成员使用下划线前缀可选: `private var _cache`

2. **缩进和格式**
   - 使用4个空格缩进，不使用Tab
   - 大括号开在行尾，不另起一行
   - 保持行宽在120字符以内
   - 操作符前后添加空格

3. **注释规范**
   - 公开API必须添加文档注释
   - 使用`///`进行文档注释
   - 复杂逻辑添加行内注释说明
   - 使用`// MARK: -`分隔代码段

示例：
```swift
/// 显示悬浮菜单
/// - Parameters:
///   - bounds: 选中文本的屏幕坐标
///   - text: 选中的文本内容
func showMenu(at bounds: NSRect, with text: String) {
    // Cancel existing timer
    hideTimer?.invalidate()
    
    // Calculate optimal position
    let position = calculateMenuPosition(for: bounds)
    
    // Show or update menu
    menuWindow?.show(at: position)
}
```

### 架构规范

1. **单一职责**: 每个类只负责一个功能模块
2. **依赖注入**: 通过构造函数传递依赖
3. **协议抽象**: 使用协议定义接口
4. **错误处理**: 使用Optional和Result类型处理错误

### Git提交规范

使用[约定式提交](https://www.conventionalcommits.org/zh-hans/)格式：

```
<类型>(<范围>): <描述>

[可选的正文]

[可选的脚注]
```

**类型说明**：
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式调整（不影响功能）
- `refactor`: 重构（不新增功能，不修复bug）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

**示例**：
```
feat(menu): 添加暗色模式支持

- 检测系统主题
- 适配菜单背景色
- 适配按钮hover颜色

Closes #123
```

## 提交流程

### 报告Bug

在提交bug报告时，请包含以下信息：

1. **环境信息**
   - macOS版本
   - 芯片类型（Intel/M1/M2/M3）
   - StudKit版本

2. **问题描述**
   - 清晰的问题描述
   - 重现步骤
   - 预期行为
   - 实际行为

3. **附加信息**
   - 截图或录屏
   - 日志输出
   - 相关应用名称

**Bug报告模板**：
```markdown
## 环境
- macOS版本: 14.0
- 芯片: M1
- StudKit版本: v1.0.0

## 问题描述
在Chrome浏览器中选择网页文本时，菜单位置偏移...

## 重现步骤
1. 打开Chrome浏览器
2. 访问任意网页
3. 选择文本
4. 观察菜单位置

## 预期行为
菜单应显示在选中文本右上角

## 实际行为
菜单显示位置偏移约50px

## 截图
[附上截图]
```

### 提出功能建议

1. 检查是否已有类似建议
2. 清晰描述功能需求和使用场景
3. 说明该功能的预期价值
4. 可选：提供设计草图或实现思路

### 提交代码

1. **Fork项目**
   ```bash
   # 在GitHub上点击Fork按钮
   ```

2. **创建功能分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **编写代码**
   - 遵循代码规范
   - 添加必要的注释
   - 确保代码可编译

4. **测试**
   ```bash
   # 编译测试
   swift build
   
   # 运行测试
   swift test  # 如果有测试
   
   # 手动测试
   .build/debug/StudKit
   ```

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

6. **推送到Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建Pull Request**
   - 在GitHub上创建PR
   - 填写PR描述，说明改动内容
   - 关联相关Issue
   - 等待代码审查

### Pull Request规范

**PR标题格式**：
```
<类型>: <简短描述>
```

**PR描述模板**：
```markdown
## 改动说明
简要说明本PR的改动内容

## 相关Issue
Closes #123

## 改动类型
- [ ] Bug修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 代码重构
- [ ] 性能优化

## 测试
- [ ] 已在本地测试
- [ ] 已在多个应用中测试
- [ ] 已测试边界情况

## 检查清单
- [ ] 代码符合项目规范
- [ ] 已添加必要注释
- [ ] 已更新相关文档
- [ ] 无编译警告
- [ ] 已手动测试功能

## 截图
如有UI改动，请附上截图
```

## 代码审查

所有PR都需要经过代码审查才能合并。审查重点：

1. **功能正确性**: 是否解决了问题
2. **代码质量**: 是否遵循规范
3. **性能影响**: 是否影响性能
4. **兼容性**: 是否破坏现有功能
5. **安全性**: 是否引入安全问题

## 开发建议

### 调试技巧

1. **使用LLDB调试**
   ```bash
   lldb .build/debug/StudKit
   (lldb) run
   ```

2. **打印日志**
   ```swift
   print("Debug: \(variable)")
   NSLog("Debug: %@", variable)
   ```

3. **Xcode调试**
   - 在Xcode中打开Package.swift
   - 设置断点调试

### 常见问题

**Q: 编译失败，提示找不到模块**
A: 清理构建缓存 `swift package clean`，然后重新构建

**Q: 权限问题导致调试困难**
A: 在系统设置中临时禁用辅助功能权限，重启应用重新触发权限请求

**Q: 如何测试不同应用的兼容性**
A: 建议测试清单：
- 原生应用: 文本编辑、Pages
- Electron应用: VS Code、Slack
- 浏览器: Chrome、Safari
- 办公软件: Word、Excel

### 性能测试

监控CPU和内存使用：
```bash
# 使用top命令
top -pid $(pgrep StudKit)

# 使用活动监视器
open -a "Activity Monitor"
```

## 发布流程

（仅限维护者）

1. 更新版本号
2. 更新CHANGELOG.md
3. 创建Git标签
4. 推送标签
5. 创建GitHub Release
6. 编译发布版本

## 社区准则

1. **友好互助**: 尊重所有贡献者
2. **建设性反馈**: 提供具体、有帮助的建议
3. **保持耐心**: 维护者可能需要时间响应
4. **开放心态**: 接受不同的观点和方案

## 许可证

通过提交代码到本项目，您同意您的贡献将在MIT许可证下发布。

## 联系方式

- 问题讨论: [GitHub Issues](https://github.com/kangkang88888/StudKit/issues)
- Pull Request: [GitHub PRs](https://github.com/kangkang88888/StudKit/pulls)

感谢您的贡献！
