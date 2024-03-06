//
//  patchfind.c
//  TrollInstallerX
//
//  Created by Alfie on 14/02/2024.
//

#include "patchfind.h"
#include <time.h>
#include <sys/mman.h>

int patchfind_kernel(const char *kernelPath) {
    if (xpf_start_with_kernel_path(kernelPath) == 0) {
        printf("Starting XPF with %s (%s)\n", kernelPath, gXPF.kernelVersionString);
        clock_t t = clock();
        
        printf("Kernel base: 0x%llx\n", gXPF.kernelBase);
        printf("Kernel entry: 0x%llx\n", gXPF.kernelEntry);
        xpf_print_all_items();
        
        xpc_object_t serializedSystemInfo = xpf_construct_offset_dictionary((const char* []) {
            "translation",
            "trustcache",
            "physmap",
            "struct",
            "physrw",
            NULL
        });
        if (serializedSystemInfo) {
            xpc_dictionary_apply(serializedSystemInfo, ^bool(const char *key, xpc_object_t value) {
                if (xpc_get_type(value) == XPC_TYPE_UINT64) {
                    printf("0x%016llx <- %s\n", xpc_uint64_get_value(value), key);
                }
                return true;
            });
            xpc_release(serializedSystemInfo);
        }
        else {
            printf("XPF Error: %s\n", xpf_get_error());
        }
        
        t = clock() - t;
        double time_taken = ((double)t)/CLOCKS_PER_SEC;
        printf("XPF finished in %lf seconds\n", time_taken);
        xpf_stop();
        return 0;
    }
    else {
        printf("Failed to start XPF: %s\n", xpf_get_error());
        return -1;
    }
}
