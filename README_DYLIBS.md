# vExploit 合并动态库编译指南

本项目提供了将 TrollInstallerX 中的 kfd 内核漏洞、dmaFail PPL 绕过和 PAC Bypass 功能合并编译为单个动态库的完整解决方案。

## 📁 项目结构

```
.
├── kfd/                          # kfd 库相关文件
│   ├── libkfd.h                 # kfd 公共 API 头文件
│   └── Makefile                 # kfd 编译配置
├── dmaFail/                     # dmaFail 库相关文件
│   ├── libdmaFail.h            # dmaFail 公共 API 头文件
│   └── Makefile                # dmaFail 编译配置
├── pacbypass/                   # PAC Bypass 库相关文件
│   ├── libPACBypass.h          # PAC Bypass 公共 API 头文件
│   └── Makefile                # PAC Bypass 编译配置
├── libvExploit.h               # 合并库的公共 API 头文件
├── build_dylibs.sh             # 完整编译脚本
├── simple_build.sh             # 简化编译脚本（快速测试）
├── full_build.sh               # 完整集成编译脚本
├── test_dylibs.c               # 测试程序
└── TrollInstallerX/            # 原始 TrollInstallerX 源码
```

**注意**: 现在所有功能（kfd + dmaFail + PAC Bypass）都合并到单个 `libvExploit.dylib` 中，只编译 arm64 架构。

## 🚀 快速开始

### 1. 准备环境

确保您的系统已安装：
- Xcode 命令行工具
- iOS SDK
- 支持 arm64 架构的编译环境

```bash
# 检查 Xcode 命令行工具
xcode-select --install

# 验证 iOS SDK
xcrun --sdk iphoneos --show-sdk-path
```

### 2. 获取源码

确保 TrollInstallerX 源码在正确位置：

```bash
# 克隆 TrollInstallerX（如果还没有）
git clone https://github.com/alfiecg24/TrollInstallerX.git

# 确保目录结构正确
ls -la TrollInstallerX/Exploitation/
```

### 3. 编译动态库

#### 方法一：简化编译（推荐用于测试）

```bash
chmod +x simple_build.sh
./simple_build.sh
```

#### 方法二：完整编译

```bash
chmod +x full_build.sh
./full_build.sh
```

#### 方法三：使用 Makefile（高级用户）

```bash
chmod +x build_dylibs.sh
./build_dylibs.sh
```

### 4. 测试编译结果

```bash
cd dist
DYLD_LIBRARY_PATH=./lib ./test_dylibs
```

## 📚 API 文档

### libvExploit.dylib - 合并的漏洞利用库

#### 库信息 API

```c
#include "libvExploit.h"

// 获取合并库版本信息
const char* vexploit_get_version(void);
const char* vexploit_get_build_info(void);
```

#### kfd 内核漏洞 API

```c

// 初始化 kfd 漏洞
uint64_t kfd_open(uint64_t puaf_pages, 
                  kfd_puaf_method_t puaf_method, 
                  kfd_kread_method_t kread_method, 
                  kfd_kwrite_method_t kwrite_method);

// 内核内存读写
void kfd_read(uint64_t kfd, uint64_t kaddr, void* uaddr, uint64_t size);
void kfd_write(uint64_t kfd, void* uaddr, uint64_t kaddr, uint64_t size);

// 清理资源
void kfd_close(uint64_t kfd);
```

#### 便捷函数

```c
// 不同数据类型的读写
uint8_t kfd_read8(uint64_t kfd, uint64_t kaddr);
uint16_t kfd_read16(uint64_t kfd, uint64_t kaddr);
uint32_t kfd_read32(uint64_t kfd, uint64_t kaddr);
uint64_t kfd_read64(uint64_t kfd, uint64_t kaddr);

void kfd_write8(uint64_t kfd, uint64_t kaddr, uint8_t value);
void kfd_write16(uint64_t kfd, uint64_t kaddr, uint16_t value);
void kfd_write32(uint64_t kfd, uint64_t kaddr, uint32_t value);
void kfd_write64(uint64_t kfd, uint64_t kaddr, uint64_t value);

// 缓冲区读写
int kfd_read_buffer(uint64_t kfd, uint64_t kaddr, void* buffer, size_t size);
int kfd_write_buffer(uint64_t kfd, uint64_t kaddr, const void* buffer, size_t size);
```

#### 初始化方法

```c
// 不同的 kfd 初始化方法
bool kfd_init_physpuppet(void);
bool kfd_init_smith(void);
bool kfd_init_landa(void);
bool kfd_deinit(void);
```

#### dmaFail PPL 绕过 API

```c

// 初始化和清理
bool dmafail_init(void);
bool dmafail_deinit(void);

// 物理内存写入
int dmafail_physwrite_buffer(uint64_t physaddr, const void* input, size_t size);
int dmafail_physwrite64(uint64_t physaddr, uint64_t value);
int dmafail_physwrite32(uint64_t physaddr, uint32_t value);
int dmafail_physwrite16(uint64_t physaddr, uint16_t value);
int dmafail_physwrite8(uint64_t physaddr, uint8_t value);
```

#### DMA 控制

```c
// DMA 操作控制
void dmafail_perform_dma(void (^block)(void));
void dmafail_halt_cpu(void);
void dmafail_unhalt_cpu(void);
void dmafail_gfx_power_init(void);
```

#### 设备检测

```c
// 设备兼容性检测
bool dmafail_is_supported(void);
uint32_t dmafail_get_cpu_family(void);
bool dmafail_is_a15_a16(void);
```

#### PAC Bypass API

```c
// 初始化和清理
bool pacbypass_init(void);
bool pacbypass_deinit(void);

// 设备检测
bool pacbypass_is_supported(void);
bool pacbypass_is_arm64e(void);
bool pacbypass_has_pac_support(void);

// PAC 操作
uint64_t pacbypass_get_pac_mask(uint64_t pointer);
uint64_t pacbypass_unsign_pointer(uint64_t pointer);
uint64_t pacbypass_kpacda(uint64_t pointer, uint64_t modifier);
uint64_t pacbypass_kptr_sign(uint64_t kaddr, uint64_t pointer, uint16_t salt);

// 内核内存操作（支持 PAC）
int pacbypass_kwrite_ptr(uint64_t kaddr, uint64_t pointer, uint16_t salt);
uint64_t pacbypass_kread_ptr(uint64_t kaddr);

// 设备信息
uint32_t pacbypass_get_cpu_family(void);
uint32_t pacbypass_get_cpu_subtype(void);
```

## 💡 使用示例

### 基本使用

```c
#include <stdio.h>
#include "libvExploit.h"

int main() {
    // 检查版本信息
    printf("vExploit version: %s\n", vexploit_get_version());
    printf("kfd version: %s\n", kfd_get_version());
    printf("dmaFail version: %s\n", dmafail_get_version());

    // 检查设备支持
    if (dmafail_is_supported()) {
        printf("dmaFail is supported on this device\n");

        // 初始化 dmaFail
        if (dmafail_init()) {
            printf("dmaFail initialized successfully\n");

            // 执行 DMA 操作
            dmafail_perform_dma(^{
                printf("Performing DMA operation...\n");
                // 在这里执行需要 PPL 绕过的操作
            });

            // 清理
            dmafail_deinit();
        }
    }

    // 使用 PAC Bypass
    if (pacbypass_is_supported() && pacbypass_init()) {
        printf("PAC Bypass is supported on this device\n");
        printf("Device is arm64e: %s\n", pacbypass_is_arm64e() ? "Yes" : "No");

        // 演示 PAC 操作
        uint64_t raw_ptr = 0x1234567890ABCDEF;
        uint64_t signed_ptr = pacbypass_kptr_sign(0xfffffff000000000, raw_ptr, 0x1234);
        uint64_t unsigned_ptr = pacbypass_unsign_pointer(signed_ptr);

        printf("Raw pointer: 0x%llx\n", raw_ptr);
        printf("Signed pointer: 0x%llx\n", signed_ptr);
        printf("Unsigned pointer: 0x%llx\n", unsigned_ptr);

        pacbypass_deinit();
    }

    return 0;
}
```

### 编译应用程序

```bash
clang -o myapp myapp.c \
    -L./dist/lib \
    -lvExploit \
    -framework Foundation \
    -arch arm64 \
    -miphoneos-version-min=14.0
```

## ⚠️ 重要说明

### 安全警告

1. **仅用于授权研究**: 这些库提供了底层系统访问能力，仅应在授权的安全研究环境中使用
2. **需要适当权限**: 使用这些库需要适当的代码签名和系统权限
3. **设备兼容性**: 不同的 iOS 版本和设备型号支持不同的漏洞利用方法

### 兼容性

- **iOS 版本**: 14.0 - 16.6.1
- **架构**: arm64 (单架构编译)
- **设备**:
  - kfd: 支持大多数 iOS 设备
  - dmaFail: 主要支持 A12+ 设备

### 限制

1. **沙盒限制**: 在沙盒环境中功能可能受限
2. **系统完整性**: 某些系统保护机制可能阻止正常运行
3. **代码签名**: 需要适当的代码签名才能在真实设备上运行

## 🔧 故障排除

### 常见问题

1. **编译失败**
   ```bash
   # 检查 Xcode 工具
   xcode-select --print-path
   
   # 重新安装命令行工具
   sudo xcode-select --reset
   xcode-select --install
   ```

2. **库加载失败**
   ```bash
   # 检查库依赖
   otool -L dist/lib/libvExploit.dylib

   # 设置库路径
   export DYLD_LIBRARY_PATH=./dist/lib:$DYLD_LIBRARY_PATH
   ```

3. **权限问题**
   ```bash
   # 确保脚本可执行
   chmod +x *.sh
   
   # 检查文件权限
   ls -la dist/lib/
   ```

### 调试模式

启用详细输出：

```bash
# 编译时启用调试信息
CFLAGS="-DDEBUG=1" ./full_build.sh

# 运行时启用详细日志
DYLD_PRINT_LIBRARIES=1 DYLD_LIBRARY_PATH=./dist/lib ./dist/test_dylibs
```

## 📄 许可证

本项目基于原始 TrollInstallerX 项目的许可证。请确保遵守相关的开源许可证要求。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 📞 支持

如果您在使用过程中遇到问题，请：

1. 检查本文档的故障排除部分
2. 查看项目的 Issue 页面
3. 提交详细的错误报告

---

**免责声明**: 本项目仅用于教育和研究目的。使用者需要自行承担使用风险，并确保遵守当地法律法规。
