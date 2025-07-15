//
//  libPACBypass.h
//  libPACBypass - Standalone PAC (Pointer Authentication Code) Bypass library
//
//  Created by Augment Agent on 2025-07-12.
//

#ifndef LIBPACBYPASS_H
#define LIBPACBYPASS_H

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// Export symbols for dynamic library
#define LIBPACBYPASS_EXPORT __attribute__((visibility("default")))

/*
 * PAC Bypass public API
 */

/**
 * Initialize PAC bypass functionality
 * This function sets up the necessary gadgets and primitives for PAC operations
 * 
 * @return true on success, false on failure
 */
LIBPACBYPASS_EXPORT bool pacbypass_init(void);

/**
 * Deinitialize PAC bypass functionality
 * Cleans up resources and restores system state
 * 
 * @return true on success, false on failure
 */
LIBPACBYPASS_EXPORT bool pacbypass_deinit(void);

/**
 * Check if current device supports PAC bypass
 * 
 * @return true if device supports PAC bypass, false otherwise
 */
LIBPACBYPASS_EXPORT bool pacbypass_is_supported(void);

/**
 * Check if current device is arm64e architecture
 * 
 * @return true if arm64e, false otherwise
 */
LIBPACBYPASS_EXPORT bool pacbypass_is_arm64e(void);

/*
 * PAC Manipulation Functions
 */

/**
 * Get PAC mask from a signed pointer
 * Extracts the PAC bits from a pointer to determine the authentication mask
 * 
 * @param pointer Signed pointer to analyze
 * @return PAC mask value
 */
LIBPACBYPASS_EXPORT uint64_t pacbypass_get_pac_mask(uint64_t pointer);

/**
 * Remove PAC signature from a pointer
 * Strips the PAC bits to get the raw pointer value
 * 
 * @param pointer Signed pointer
 * @return Unsigned pointer
 */
LIBPACBYPASS_EXPORT uint64_t pacbypass_unsign_pointer(uint64_t pointer);

/**
 * Sign a pointer with PAC using kernel PACDA instruction
 * Uses kernel execution to sign a pointer with the specified modifier
 * 
 * @param pointer Raw pointer to sign
 * @param modifier PAC modifier/context value
 * @return Signed pointer
 */
LIBPACBYPASS_EXPORT uint64_t pacbypass_kpacda(uint64_t pointer, uint64_t modifier);

/**
 * Sign a kernel pointer with address and salt
 * Creates a properly signed kernel pointer using address context and salt
 * 
 * @param kaddr Kernel address context
 * @param pointer Raw pointer to sign
 * @param salt Salt value for signing
 * @return Signed pointer
 */
LIBPACBYPASS_EXPORT uint64_t pacbypass_kptr_sign(uint64_t kaddr, uint64_t pointer, uint16_t salt);

/*
 * Kernel Memory Operations with PAC Support
 */

/**
 * Write a signed pointer to kernel memory
 * Properly signs the pointer before writing to kernel address space
 * 
 * @param kaddr Kernel address to write to
 * @param pointer Raw pointer value
 * @param salt Salt for PAC signing
 * @return 0 on success, negative on error
 */
LIBPACBYPASS_EXPORT int pacbypass_kwrite_ptr(uint64_t kaddr, uint64_t pointer, uint16_t salt);

/**
 * Read and unsign a pointer from kernel memory
 * Reads a signed pointer and returns the unsigned value
 * 
 * @param kaddr Kernel address to read from
 * @return Unsigned pointer value
 */
LIBPACBYPASS_EXPORT uint64_t pacbypass_kread_ptr(uint64_t kaddr);

/*
 * Process Credential Manipulation with PAC Support
 */

/**
 * Get process credentials with PAC handling
 * Safely reads process credentials accounting for PAC-signed pointers
 * 
 * @param proc Process structure address
 * @param is_ios14 Whether running on iOS 14 (affects offsets)
 * @param cred_out Output buffer for credentials
 * @return 0 on success, negative on error
 */
LIBPACBYPASS_EXPORT int pacbypass_proc_get_cred(uint64_t proc, bool is_ios14, void* cred_out);

/**
 * Set process credentials with PAC handling
 * Safely writes process credentials with proper PAC signing
 * 
 * @param proc Process structure address
 * @param cred Credentials to write
 * @param is_ios14 Whether running on iOS 14 (affects offsets)
 * @return 0 on success, negative on error
 */
LIBPACBYPASS_EXPORT int pacbypass_proc_set_cred(uint64_t proc, const void* cred, bool is_ios14);

/*
 * Kernel Execution with PAC Support
 */

/**
 * Execute kernel function with PAC-aware calling convention
 * Properly handles PAC-signed function pointers and return addresses
 * 
 * @param func_addr Kernel function address
 * @param argc Number of arguments
 * @param argv Array of arguments
 * @param result_out Output for return value
 * @return 0 on success, negative on error
 */
LIBPACBYPASS_EXPORT int pacbypass_kcall(uint64_t func_addr, int argc, const uint64_t* argv, uint64_t* result_out);

/*
 * Thread and Task Operations with PAC Support
 */

/**
 * Sign kernel thread with proper PAC authentication
 * Ensures thread structures have valid PAC signatures
 * 
 * @param proc Process structure address
 * @param thread_port Mach port for the thread
 * @return 0 on success, negative on error
 */
LIBPACBYPASS_EXPORT int pacbypass_sign_kernel_thread(uint64_t proc, uint32_t thread_port);

/*
 * Utility Functions
 */

/**
 * Get CPU family information
 * 
 * @return CPU family identifier
 */
LIBPACBYPASS_EXPORT uint32_t pacbypass_get_cpu_family(void);

/**
 * Get CPU subtype information
 * 
 * @return CPU subtype identifier
 */
LIBPACBYPASS_EXPORT uint32_t pacbypass_get_cpu_subtype(void);

/**
 * Check if running on specific CPU families that affect PAC behavior
 * 
 * @return true if running on A12+ with PAC support
 */
LIBPACBYPASS_EXPORT bool pacbypass_has_pac_support(void);

/*
 * Version and build information
 */

/**
 * Get library version string
 * 
 * @return Version string
 */
LIBPACBYPASS_EXPORT const char* pacbypass_get_version(void);

/**
 * Get build information string
 * 
 * @return Build info string
 */
LIBPACBYPASS_EXPORT const char* pacbypass_get_build_info(void);

/*
 * Error codes
 */
#define PACBYPASS_SUCCESS               0
#define PACBYPASS_ERROR_INIT_FAILED    -1
#define PACBYPASS_ERROR_NOT_SUPPORTED  -2
#define PACBYPASS_ERROR_INVALID_POINTER -3
#define PACBYPASS_ERROR_GADGET_MISSING  -4
#define PACBYPASS_ERROR_KEXEC_FAILED    -5

/**
 * Get error string for error code
 * 
 * @param error_code Error code returned by pacbypass functions
 * @return Human-readable error string
 */
LIBPACBYPASS_EXPORT const char* pacbypass_get_error_string(int error_code);

/*
 * PAC Constants and Masks
 */
#define PAC_MASK_DEFAULT    0xFFFF000000000000ULL
#define PAC_SIGN_BIT        55
#define PAC_POINTER_MASK    0x0000FFFFFFFFFFFFULL

#ifdef __cplusplus
}
#endif

#endif /* LIBPACBYPASS_H */
