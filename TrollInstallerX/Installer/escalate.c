//
//  escalate.c
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

#include <stdio.h>
#include <xpf/xpf.h>
#include <libjailbreak/info.h>
#include <libjailbreak/translation.h>
#include <libjailbreak/primitives_IOSurface.h>
#include <libjailbreak/kalloc_pt.h>
#include <libjailbreak/physrw_pte.h>
#include <libjailbreak/util.h>
#include <libjailbreak/kernel.h>
#include <libjailbreak/primitives.h>
#include <libjailbreak/codesign.h>


void post_kernel_exploit(bool iOS14) {
    if (!iOS14) {
        jbinfo_initialize_boot_constants();
    }
    libjailbreak_translation_init();
    libjailbreak_IOSurface_primitives_init();
}

bool build_physrw_primitive(void) {
    int r = libjailbreak_physrw_pte_init(false);
    return r == 0;
}

struct k_posix_cred backup_cred;
int backup_groupSize;
gid_t backup_groupList[200];

// 14.0 - 15.1.1 (arm64e)
// 14.0 - 14.8.1 (arm64)
bool get_root_krw(bool iOS14) {
    
    // Get the address of our (TrollInstallerX) proc structure
    uint64_t proc = gSystemInfo.kernelConstant.currentProc;
    
    printf("Attempting Xina escalation method...\n");
    
    backup_groupSize = getgroups(200, &backup_groupList[0]);
    backup_cred = proc_get_posix_cred(proc, iOS14);
    
    struct k_posix_cred zero_cred = {0};
    
    // Set new cred with everything zeroed (sandbox, root etc.)
    printf("Setting posix cred to zero cred\n");
    usleep(1000);
    proc_set_posix_cred(proc, zero_cred, iOS14);
    
    int error = setgroups(0, 0);
    if (error) {
        printf("setgroups failed with error code %d\n", error);
        return false;
    }
    
    // Root?
    int uid = getuid();
    printf("getuid() -> %d\n", uid);
    
    return uid == 0;
}

bool drop_root_krw(bool iOS14) {
    if (getuid() != 0) return true;
    printf("Dropping root...\n");
    
    // Get the address of our (TrollInstallerX) proc structure
    uint64_t proc = gSystemInfo.kernelConstant.currentProc;
    
    int error = setgroups(backup_groupSize, backup_groupList);
    if (error) {
        printf("setgroups failed with error code %d\n", error);
    }
    
    proc_set_posix_cred(proc, backup_cred, iOS14);
    
    uid_t uid = getuid();
    printf("getuid() -> %d\n", uid);
    
    return true;
}

// 15.2 - 16.5.1 (arm64e)
// 15.0 - 16.6.1 (arm64)
bool get_root_pplrw(void) {
    uint64_t proc = proc_self();
    uint64_t ucred = proc_ucred(proc);
    
    // Give ourselves UID 0
    kwrite32(proc + koffsetof(proc, svuid), 0);
    kwrite32(ucred + koffsetof(ucred, svuid), 0);
    kwrite32(ucred + koffsetof(ucred, ruid), 0);
    kwrite32(ucred + koffsetof(ucred, uid), 0);
    
    // Give ourselves GID 0
    kwrite32(proc + koffsetof(proc, svgid), 0);
    kwrite32(ucred + koffsetof(ucred, rgid), 0);
    kwrite32(ucred + koffsetof(ucred, svgid), 0);
    kwrite32(ucred + koffsetof(ucred, groups), 0);
    
    // Add P_SUGID
    uint32_t flag = kread32(proc + koffsetof(proc, flag));
    if ((flag & P_SUGID) != 0) {
        flag &= P_SUGID;
        kwrite32(proc + koffsetof(proc, flag), flag);
    }
    
    if (getuid() != 0 || getgid() != 0) {
        printf("getuid()=%d, getgid()=%d\n", getuid(), getgid());
        return false;
    }
    
    return true;
}

bool unsandbox(void) {
    uint64_t proc = proc_self();
    uint64_t ucred = proc_ucred(proc);
    uint64_t label = kread_ptr(ucred + koffsetof(ucred, label));
    mac_label_set(label, 1, -1);
    return true;
}

bool platformise(void) {
    uint64_t proc = proc_self();
    proc_csflags_set(proc, CS_PLATFORM_BINARY);
    uint32_t csflags;
    csops(getpid(), CS_OPS_STATUS, &csflags, sizeof(csflags));
    if (!(csflags & CS_PLATFORM_BINARY)) {
        return false;
    }
    return true;
}
