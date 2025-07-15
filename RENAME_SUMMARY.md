# 🔄 库重命名总结：TrollExploit → vExploit

## ✅ 重命名完成

已成功将 **TrollExploit Library** 重命名为 **vExploit Library**。

## 📋 更改详情

### 🗂️ 文件重命名

| 原文件名 | 新文件名 |
|---------|---------|
| `libTrollExploit.h` | `libvExploit.h` |
| `demo_trollexploit.c` | `demo_vexploit.c` |

### 🔧 函数重命名

| 原函数名 | 新函数名 |
|---------|---------|
| `trollexploit_get_version()` | `vexploit_get_version()` |
| `trollexploit_get_build_info()` | `vexploit_get_build_info()` |
| `TROLLEXPLOIT_EXPORT` | `VEXPLOIT_EXPORT` |

### 📦 库文件重命名

| 原库名 | 新库名 |
|-------|-------|
| `libTrollExploit.dylib` | `libvExploit.dylib` |
| `-lTrollExploit` | `-lvExploit` |
| `@rpath/libTrollExploit.dylib` | `@rpath/libvExploit.dylib` |

### 📚 文档更新

以下文档已更新以反映新的库名称：

- ✅ `README_DYLIBS.md` - 主要文档
- ✅ `BUILD_GUIDE.md` - 构建指南
- ✅ `simple_build.sh` - 简化构建脚本
- ✅ `full_build.sh` - 完整构建脚本
- ✅ `test_dylibs.c` - 测试程序
- ✅ `demo_vexploit.c` - 演示程序

## 🚀 使用新的 vExploit 库

### 快速开始

```bash
# 构建 vExploit 库
./simple_build.sh

# 测试库
cd dist && DYLD_LIBRARY_PATH=./lib ./test_dylibs

# 运行演示
cd dist && DYLD_LIBRARY_PATH=./lib ./demo_vexploit
```

### API 使用

```c
#include "libvExploit.h"

int main() {
    // 获取版本信息
    printf("vExploit: %s\n", vexploit_get_version());
    printf("Build: %s\n", vexploit_get_build_info());
    
    // 使用 kfd
    uint64_t kfd = kfd_open(512, KFD_PUAF_LANDA, 
                           KFD_KREAD_IOSURFACE, KFD_KWRITE_IOSURFACE);
    
    // 使用 dmaFail
    if (dmafail_is_supported() && dmafail_init()) {
        dmafail_physwrite64(0x200000000, 0x1234567890ABCDEF);
        dmafail_deinit();
    }
    
    // 使用 PAC Bypass
    if (pacbypass_is_supported() && pacbypass_init()) {
        uint64_t signed_ptr = pacbypass_kptr_sign(kaddr, ptr, salt);
        pacbypass_deinit();
    }
    
    return 0;
}
```

### 编译链接

```bash
clang -o myapp myapp.c \
    -L./dist/lib \
    -lvExploit \
    -framework Foundation \
    -arch arm64 \
    -miphoneos-version-min=14.0
```

## 📊 库特性（保持不变）

### 核心功能
- ✅ **kfd 内核漏洞** - 内核内存读写
- ✅ **dmaFail PPL 绕过** - 物理内存直接访问
- ✅ **PAC Bypass** - 指针认证绕过

### 技术规格
- **架构**: arm64 (单架构编译)
- **兼容性**: iOS 14.0 - 16.6.1
- **API 函数**: 40+ 个公共函数
- **库大小**: 优化的单一动态库

### 设备支持
- **kfd**: 支持大多数 iOS 设备
- **dmaFail**: 主要支持 A12+ 设备
- **PAC Bypass**: 支持 A12+ arm64e 设备

## 🔍 验证重命名

```bash
# 检查生成的库
ls -la dist/lib/
# 应该看到: libvExploit.dylib

# 检查头文件
ls -la dist/include/
# 应该看到: libvExploit.h
```

## ⚠️ 重要提醒

### 更新现有项目

如果您之前使用过 TrollExploit 库，需要更新：

1. **头文件包含**:
   ```c
   // 旧的
   #include "libTrollExploit.h"
   
   // 新的
   #include "libvExploit.h"
   ```

2. **函数调用**:
   ```c
   // 旧的
   trollexploit_get_version()
   
   // 新的
   vexploit_get_version()
   ```

3. **链接库**:
   ```bash
   # 旧的
   -lTrollExploit
   
   # 新的
   -lvExploit
   ```

### 向后兼容性

⚠️ **注意**: 此重命名不向后兼容。使用旧 API 的代码需要更新。

## 🎉 重命名完成

vExploit 库现在已准备就绪，提供与之前相同的强大功能，但使用了新的、更简洁的命名方案。

**主要优势**:
- 🎯 **简洁命名** - vExploit 比 TrollExploit 更简短
- 🔧 **保持功能** - 所有原有功能完全保留
- 📚 **文档完整** - 所有文档已同步更新
- 🚀 **易于使用** - API 使用方式保持一致

开始使用新的 vExploit 库吧！
