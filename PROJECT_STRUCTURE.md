# 📁 vExploit 项目结构

## 🎯 核心文件

```
vExploit-Project/
├── 📄 libvExploit.h              # 合并库的统一 API 头文件
├── 🧪 demo_vexploit.c            # 完整功能演示程序
├── 🧪 test_dylibs.c              # 基础测试程序
└── 📚 文档文件...
```

## 🔧 构建脚本

```
├── 🔧 simple_build.sh            # 简化编译脚本（推荐）
├── 🔧 full_build.sh              # 完整集成编译脚本
├── 🔧 build_dylibs.sh            # 高级编译脚本
├── 🔧 clean.sh                   # 清理脚本
└── 🔧 setup.sh                   # 环境设置脚本
```

## 📁 组件目录

```
├── 📁 kfd/                       # kfd 内核漏洞组件
│   ├── libkfd.h                  # kfd API 头文件
│   └── Makefile                  # kfd 编译配置
├── 📁 dmaFail/                   # dmaFail PPL 绕过组件
│   ├── libdmaFail.h             # dmaFail API 头文件
│   └── Makefile                 # dmaFail 编译配置
└── 📁 pacbypass/                 # PAC Bypass 组件
    ├── libPACBypass.h           # PAC Bypass API 头文件
    └── Makefile                 # PAC Bypass 编译配置
```

## 📚 文档文件

```
├── 📚 README_DYLIBS.md           # 主要使用文档
├── 📚 BUILD_GUIDE.md             # 构建指南
├── 📚 QUICK_START.md             # 快速开始指南
├── 📚 RENAME_SUMMARY.md          # 重命名说明
├── 📚 SUMMARY.md                 # 项目总结
└── 📚 FINAL_SUMMARY.md           # 最终总结
```

## 🏗️ 构建输出

```
└── 📁 dist/                      # 构建输出目录
    ├── 📁 lib/
    │   └── libvExploit.dylib     # 合并的动态库
    ├── 📁 include/
    │   ├── libvExploit.h         # 主头文件
    │   ├── libkfd.h              # kfd 头文件
    │   ├── libdmaFail.h          # dmaFail 头文件
    │   └── libPACBypass.h        # PAC Bypass 头文件
    ├── test_dylibs               # 测试程序
    └── demo_vexploit             # 演示程序
```

## 🚀 使用流程

### 1. 快速开始
```bash
./clean.sh && ./simple_build.sh
```

### 2. 测试验证
```bash
cd dist && DYLD_LIBRARY_PATH=./lib ./demo_vexploit
```

### 3. 集成使用
```c
#include "libvExploit.h"
// 链接: -lvExploit
```

## 📋 文件说明

### 核心库文件
- **`libvExploit.h`** - 统一的 API 头文件，包含所有功能
- **`libvExploit.dylib`** - 编译后的动态库文件

### 构建脚本
- **`simple_build.sh`** - 推荐使用，快速构建
- **`full_build.sh`** - 完整构建，包含更多集成
- **`build_dylibs.sh`** - 高级构建，使用 Makefile
- **`clean.sh`** - 清理所有构建文件
- **`setup.sh`** - 环境检查和设置

### 测试程序
- **`test_dylibs.c`** - 基础功能测试
- **`demo_vexploit.c`** - 完整功能演示

### 组件头文件
- **`kfd/libkfd.h`** - kfd 内核漏洞 API
- **`dmaFail/libdmaFail.h`** - dmaFail PPL 绕过 API
- **`pacbypass/libPACBypass.h`** - PAC Bypass API

## 🎯 推荐工作流

```bash
# 1. 清理环境
./clean.sh

# 2. 构建库
./simple_build.sh

# 3. 测试功能
cd dist
DYLD_LIBRARY_PATH=./lib ./test_dylibs
DYLD_LIBRARY_PATH=./lib ./demo_vexploit

# 4. 集成到项目
cp dist/lib/libvExploit.dylib /path/to/project/
cp dist/include/libvExploit.h /path/to/project/
```

## 📊 项目统计

- **总文件数**: ~15 个核心文件
- **代码行数**: ~3000+ 行
- **支持架构**: arm64
- **支持 iOS**: 14.0 - 16.6.1
- **API 函数**: 40+ 个
- **组件数量**: 3 个（kfd + dmaFail + PAC Bypass）

## 🔧 维护

```bash
# 完整重建
./clean.sh && ./simple_build.sh

# 清理临时文件
./clean.sh
```

这个项目结构设计简洁明了，易于使用和维护。
