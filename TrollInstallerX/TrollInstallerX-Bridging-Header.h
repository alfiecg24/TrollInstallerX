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
#include "grabkernel/appledb.h"
#include "grabkernel/grabkernel.h"

// XPF patchfinder
#include "patchfinding/patchfind.h"

// MacDirtyCow
#include "MacDirtyCow/grant_full_disk_access.h"
#include "MacDirtyCow/vm_unaligned_copy_switch_race.h"

// dmaFail

// kfd

CFPropertyListRef MGCopyAnswer(CFStringRef property);

#endif /* TrollInstallerX_Bridging_Header_h */
