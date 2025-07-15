# 🔧 构建指南 - vExploit vs TrollInstallerX

## ⚠️ 重要说明

这个项目包含两个不同的构建目标，请根据您的需求选择正确的构建脚本：

## 🎯 选择正确的构建脚本

### 1. 构建 vExploit 动态库（推荐）

如果您想要构建我们创建的 **vExploit 合并动态库**（kfd + dmaFail + PAC Bypass），请使用：

```bash
# 快速构建（推荐）
./simple_build.sh

# 或者完整构建
./full_build.sh

# 或者高级构建
./build_dylibs.sh
```

**输出**: `dist/lib/libvExploit.dylib` - 合并的动态库

### 2. 构建原始 TrollInstallerX 应用

如果您想要构建原始的 **TrollInstallerX iOS 应用**，请使用：

```bash
# 需要先安装 ldid
./install_ldid.sh

# 然后构建应用
./build.sh
```

**输出**: `TrollInstallerX.ipa` - iOS 应用安装包

## 🚨 错误解决

### `ldid: command not found` 错误

这个错误出现在运行 `./build.sh` 时，表示您在尝试构建原始的 TrollInstallerX 应用。

**解决方案**:

#### 选项 1: 构建 vExploit 库（推荐）
```bash
# 使用我们的库构建脚本
./simple_build.sh
```

#### 选项 2: 安装 ldid 并构建原始应用
```bash
# 安装 ldid
./install_ldid.sh

# 构建原始应用
./build.sh
```

## 📋 脚本对比

| 脚本 | 用途 | 输出 | 依赖 |
|------|------|------|------|
| `./simple_build.sh` | 构建 vExploit 库 | `libvExploit.dylib` | Xcode 工具链 |
| `./full_build.sh` | 完整构建 vExploit 库 | `libvExploit.dylib` | Xcode 工具链 |
| `./build_dylibs.sh` | 高级构建 vExploit 库 | `libvExploit.dylib` | Xcode 工具链 |
| `./build.sh` | 构建原始 TrollInstallerX 应用 | `TrollInstallerX.ipa` | Xcode + ldid |

## 🎯 推荐工作流程

### 对于 vExploit 库开发

```bash
# 1. 清理环境
./clean.sh

# 2. 快速构建
./simple_build.sh

# 3. 测试库
cd dist && DYLD_LIBRARY_PATH=./lib ./test_dylibs

# 4. 完整演示
cd dist && DYLD_LIBRARY_PATH=./lib ./demo_trollexploit
```

### 对于原始 TrollInstallerX 应用

```bash
# 1. 安装依赖
./install_ldid.sh

# 2. 构建应用
./build.sh

# 3. 安装到设备
# 使用 Xcode 或其他工具安装 TrollInstallerX.ipa
```

## 🔍 故障排除

### 1. `ldid: command not found`
- **原因**: 尝试构建原始应用但缺少 ldid 工具
- **解决**: 运行 `./install_ldid.sh` 或使用 `./simple_build.sh`

### 2. `xcodebuild: command not found`
- **原因**: 缺少 Xcode 命令行工具
- **解决**: 运行 `xcode-select --install`

### 3. `No such file or directory: TrollInstallerX`
- **原因**: 在错误的目录运行脚本
- **解决**: 确保在项目根目录运行

### 4. 权限错误
- **原因**: 脚本没有执行权限
- **解决**: 运行 `chmod +x *.sh`

## 📚 更多信息

- **TrollExploit 库文档**: 查看 `README_DYLIBS.md`
- **项目总结**: 查看 `SUMMARY.md` 和 `FINAL_SUMMARY.md`
- **API 文档**: 查看 `libTrollExploit.h`

## 💡 建议

对于大多数用户，我们推荐使用 **vExploit 动态库**，因为它：

- ✅ 更容易集成到其他项目
- ✅ 提供清晰的 API 接口
- ✅ 支持模块化使用
- ✅ 包含完整的文档和示例
- ✅ 不需要额外的签名工具

如果您需要完整的 TrollInstallerX 应用，请使用原始的构建流程。
