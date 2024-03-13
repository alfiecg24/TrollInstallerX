//
//  TrollInstallerX-Bridging-Header.h
//  TrollInstallerX
//
//  Created by Alfie on 10/02/2024.
//

#ifndef TrollInstallerX_Bridging_Header_h
#define TrollInstallerX_Bridging_Header_h

#include <Foundation/Foundation.h>

// Kernel grabber
#include <libgrabkernel2/libgrabkernel2.h>

// XPF patchfinder
#include "patchfinder/patchfind.h"

// Kernel information
#include "Post-Exploitation/post_exploitation.h"

// MacDirtyCow
#include "MacDirtyCow/grant_full_disk_access.h"
#include "MacDirtyCow/vm_unaligned_copy_switch_race.h"

// kfd
#include "kfd/kfd.h"

// dmaFail
#include "dmaFail/dmaFail.h"

// TrollStore installation
#include <libjailbreak/util.h>
#include "TrollStore/install.h"

#import <sys/sysctl.h>
bool isArm64e(void) {
    cpu_subtype_t cpusubtype = 0;
    size_t len = sizeof(cpusubtype);
    if (sysctlbyname("hw.cpusubtype", &cpusubtype, &len, NULL, 0) == -1) { return NO; }
    return (cpusubtype & ~CPU_SUBTYPE_MASK) == CPU_SUBTYPE_ARM64E;
}

#endif /* TrollInstallerX_Bridging_Header_h */
