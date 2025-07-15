/*
 * test_dylibs.c
 * Test program for libvExploit dynamic library (combined kfd + dmaFail + PAC Bypass)
 *
 * Created by Augment Agent on 2025-07-12.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <dlfcn.h>
#include <sys/sysctl.h>

// Function pointer types for dynamic loading
typedef const char* (*get_version_func_t)(void);
typedef const char* (*get_build_info_func_t)(void);
typedef bool (*init_func_t)(void);
typedef bool (*deinit_func_t)(void);
typedef bool (*is_supported_func_t)(void);
typedef uint32_t (*get_cpu_family_func_t)(void);
typedef bool (*is_a15_a16_func_t)(void);

// Test libvExploit
int test_libvexploit(void) {
    printf("\n=== Testing libvExploit.dylib ===\n");

    // Load the library
    void *handle = dlopen("./lib/libvExploit.dylib", RTLD_LAZY);
    if (!handle) {
        printf("ERROR: Cannot load libvExploit.dylib: %s\n", dlerror());
        return -1;
    }
    
    // Get function pointers for combined library
    get_version_func_t vexploit_get_version = dlsym(handle, "vexploit_get_version");
    get_build_info_func_t vexploit_get_build_info = dlsym(handle, "vexploit_get_build_info");

    // kfd functions
    get_version_func_t kfd_get_version = dlsym(handle, "kfd_get_version");
    get_build_info_func_t kfd_get_build_info = dlsym(handle, "kfd_get_build_info");
    init_func_t kfd_init_landa = dlsym(handle, "kfd_init_landa");
    deinit_func_t kfd_deinit = dlsym(handle, "kfd_deinit");

    // dmaFail functions
    get_version_func_t dmafail_get_version = dlsym(handle, "dmafail_get_version");
    get_build_info_func_t dmafail_get_build_info = dlsym(handle, "dmafail_get_build_info");
    is_supported_func_t dmafail_is_supported = dlsym(handle, "dmafail_is_supported");
    get_cpu_family_func_t dmafail_get_cpu_family = dlsym(handle, "dmafail_get_cpu_family");
    is_a15_a16_func_t dmafail_is_a15_a16 = dlsym(handle, "dmafail_is_a15_a16");

    // PAC Bypass functions
    get_version_func_t pacbypass_get_version = dlsym(handle, "pacbypass_get_version");
    get_build_info_func_t pacbypass_get_build_info = dlsym(handle, "pacbypass_get_build_info");
    is_supported_func_t pacbypass_is_supported = dlsym(handle, "pacbypass_is_supported");
    is_supported_func_t pacbypass_is_arm64e = dlsym(handle, "pacbypass_is_arm64e");
    is_supported_func_t pacbypass_has_pac_support = dlsym(handle, "pacbypass_has_pac_support");

    if (!vexploit_get_version || !kfd_get_version || !dmafail_get_version || !pacbypass_get_version) {
        printf("ERROR: Cannot find required symbols in libvExploit.dylib\n");
        dlclose(handle);
        return -1;
    }

    // Test combined library info
    printf("=== Combined Library Info ===\n");
    printf("vExploit version: %s\n", vexploit_get_version());
    printf("vExploit build info: %s\n", vexploit_get_build_info());

    // Test kfd functions
    printf("\n=== kfd Functions ===\n");
    printf("kfd version: %s\n", kfd_get_version());
    printf("kfd build info: %s\n", kfd_get_build_info());
    
    // Test dmaFail functions
    printf("\n=== dmaFail Functions ===\n");
    printf("dmaFail version: %s\n", dmafail_get_version());
    printf("dmaFail build info: %s\n", dmafail_get_build_info());
    
    if (dmafail_get_cpu_family) {
        uint32_t cpu_family = dmafail_get_cpu_family();
        printf("CPU Family: 0x%08x\n", cpu_family);
        
        // Decode CPU family
        switch (cpu_family) {
            case 0x07d34b9f:
                printf("CPU: A12 (Vortex/Tempest)\n");
                break;
            case 0x462504d2:
                printf("CPU: A13 (Lightning/Thunder)\n");
                break;
            case 0x8765edea:
                printf("CPU: A14 (Firestorm/Icestorm)\n");
                break;
            case 0x1b588bb3:
                printf("CPU: A15 (Avalanche/Blizzard)\n");
                break;
            case 0xda33d83d:
                printf("CPU: A16 (Everest/Sawtooth)\n");
                break;
            default:
                printf("CPU: Unknown (0x%08x)\n", cpu_family);
                break;
        }
    }
    
    if (dmafail_is_a15_a16) {
        printf("Is A15/A16: %s\n", dmafail_is_a15_a16() ? "Yes" : "No");
    }
    
    if (dmafail_is_supported) {
        printf("dmaFail supported: %s\n", dmafail_is_supported() ? "Yes" : "No");
    }

    // Test PAC Bypass functions
    printf("\n=== PAC Bypass Functions ===\n");
    printf("PAC Bypass version: %s\n", pacbypass_get_version());
    printf("PAC Bypass build info: %s\n", pacbypass_get_build_info());

    if (pacbypass_is_arm64e) {
        printf("Is arm64e: %s\n", pacbypass_is_arm64e() ? "Yes" : "No");
    }

    if (pacbypass_has_pac_support) {
        printf("Has PAC support: %s\n", pacbypass_has_pac_support() ? "Yes" : "No");
    }

    if (pacbypass_is_supported) {
        printf("PAC Bypass supported: %s\n", pacbypass_is_supported() ? "Yes" : "No");
    }

    // Test initialization (commented out for safety in test environment)
    /*
    if (kfd_init_landa && kfd_deinit) {
        printf("Testing kfd initialization...\n");
        if (kfd_init_landa()) {
            printf("kfd initialization successful\n");
            kfd_deinit();
            printf("kfd deinitialization successful\n");
        } else {
            printf("kfd initialization failed (expected in test environment)\n");
        }
    }
    */

    printf("libvExploit.dylib test completed successfully\n");
    dlclose(handle);
    return 0;
}

// Get system information
void print_system_info(void) {
    printf("\n=== System Information ===\n");
    
    // Get iOS version
    char version[256];
    size_t size = sizeof(version);
    if (sysctlbyname("kern.version", version, &size, NULL, 0) == 0) {
        printf("Kernel version: %.100s...\n", version);
    }
    
    // Get device model
    char model[256];
    size = sizeof(model);
    if (sysctlbyname("hw.model", model, &size, NULL, 0) == 0) {
        printf("Device model: %s\n", model);
    }
    
    // Get CPU info
    uint32_t cpu_family;
    size = sizeof(cpu_family);
    if (sysctlbyname("hw.cpufamily", &cpu_family, &size, NULL, 0) == 0) {
        printf("CPU family: 0x%08x\n", cpu_family);
    }
    
    uint32_t cpu_type;
    size = sizeof(cpu_type);
    if (sysctlbyname("hw.cputype", &cpu_type, &size, NULL, 0) == 0) {
        printf("CPU type: 0x%08x\n", cpu_type);
    }
    
    uint32_t cpu_subtype;
    size = sizeof(cpu_subtype);
    if (sysctlbyname("hw.cpusubtype", &cpu_subtype, &size, NULL, 0) == 0) {
        printf("CPU subtype: 0x%08x\n", cpu_subtype);
    }
    
    // Get memory info
    uint64_t memsize;
    size = sizeof(memsize);
    if (sysctlbyname("hw.memsize", &memsize, &size, NULL, 0) == 0) {
        printf("Memory size: %llu MB\n", memsize / (1024 * 1024));
    }
}

int main(int argc, char *argv[]) {
    printf("libvExploit Dynamic Library Test\n");
    printf("================================\n");

    print_system_info();

    int result = 0;

    // Test combined library
    if (test_libvexploit() != 0) {
        result = -1;
    }

    if (result == 0) {
        printf("\n✅ All tests passed successfully!\n");
    } else {
        printf("\n❌ Some tests failed!\n");
    }

    return result;
}
