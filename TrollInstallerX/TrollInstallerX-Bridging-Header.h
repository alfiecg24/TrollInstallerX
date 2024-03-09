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
#include "Exploits/Haxx.h"

// MacDirtyCow
#include "MacDirtyCow/grant_full_disk_access.h"
#include "MacDirtyCow/vm_unaligned_copy_switch_race.h"

// kfd
#include "kfd/kfd.h"

// dmaFail
#include "dmaFail/dmaFail.h"

#endif /* TrollInstallerX_Bridging_Header_h */
