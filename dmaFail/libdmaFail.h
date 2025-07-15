//
//  libdmaFail.h
//  libdmaFail - Standalone dmaFail PPL bypass library
//
//  Created by Augment Agent on 2025-07-12.
//

#ifndef LIBDMAFAIL_H
#define LIBDMAFAIL_H

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// Export symbols for dynamic library
#define LIBDMAFAIL_EXPORT __attribute__((visibility("default")))

/*
 * dmaFail PPL bypass public API
 */

/**
 * Initialize dmaFail PPL bypass
 * This function sets up the necessary mappings and hardware access
 * for performing PPL (Page Protection Layer) bypass operations.
 * 
 * @return true on success, false on failure
 */
LIBDMAFAIL_EXPORT bool dmafail_init(void);

/**
 * Deinitialize dmaFail PPL bypass
 * Cleans up mappings and restores system state
 * 
 * @return true on success, false on failure
 */
LIBDMAFAIL_EXPORT bool dmafail_deinit(void);

/**
 * Write to physical memory using DMA bypass
 * This function bypasses PPL protections to write directly to physical memory
 * 
 * @param physaddr Physical address to write to
 * @param input Buffer containing data to write
 * @param size Number of bytes to write
 * @return 0 on success, negative on error
 */
LIBDMAFAIL_EXPORT int dmafail_physwrite_buffer(uint64_t physaddr, const void* input, size_t size);

/**
 * Write 64-bit value to physical memory
 * 
 * @param physaddr Physical address to write to
 * @param value 64-bit value to write
 * @return 0 on success, negative on error
 */
LIBDMAFAIL_EXPORT int dmafail_physwrite64(uint64_t physaddr, uint64_t value);

/**
 * Write 32-bit value to physical memory
 * 
 * @param physaddr Physical address to write to
 * @param value 32-bit value to write
 * @return 0 on success, negative on error
 */
LIBDMAFAIL_EXPORT int dmafail_physwrite32(uint64_t physaddr, uint32_t value);

/**
 * Write 16-bit value to physical memory
 * 
 * @param physaddr Physical address to write to
 * @param value 16-bit value to write
 * @return 0 on success, negative on error
 */
LIBDMAFAIL_EXPORT int dmafail_physwrite16(uint64_t physaddr, uint16_t value);

/**
 * Write 8-bit value to physical memory
 * 
 * @param physaddr Physical address to write to
 * @param value 8-bit value to write
 * @return 0 on success, negative on error
 */
LIBDMAFAIL_EXPORT int dmafail_physwrite8(uint64_t physaddr, uint8_t value);

/**
 * Perform DMA operation with custom block
 * This function handles the CPU halting and DMA setup/teardown
 * while executing the provided block
 * 
 * @param block Block to execute during DMA operation
 */
LIBDMAFAIL_EXPORT void dmafail_perform_dma(void (^block)(void));

/*
 * Hardware control functions
 */

/**
 * Halt CPU for DMA operations
 * This function halts the CPU to allow safe DMA operations
 */
LIBDMAFAIL_EXPORT void dmafail_halt_cpu(void);

/**
 * Unhalt CPU after DMA operations
 * This function resumes CPU operation after DMA is complete
 */
LIBDMAFAIL_EXPORT void dmafail_unhalt_cpu(void);

/**
 * Initialize graphics hardware for DMA
 * Powers on the graphics subsystem required for DMA operations
 */
LIBDMAFAIL_EXPORT void dmafail_gfx_power_init(void);

/*
 * Utility functions
 */

/**
 * Check if current device supports dmaFail
 * 
 * @return true if device supports dmaFail, false otherwise
 */
LIBDMAFAIL_EXPORT bool dmafail_is_supported(void);

/**
 * Get CPU family information
 * 
 * @return CPU family identifier
 */
LIBDMAFAIL_EXPORT uint32_t dmafail_get_cpu_family(void);

/**
 * Check if device is A15/A16 family
 * 
 * @return true if A15/A16, false otherwise
 */
LIBDMAFAIL_EXPORT bool dmafail_is_a15_a16(void);

/*
 * Version and build information
 */

/**
 * Get library version string
 * 
 * @return Version string
 */
LIBDMAFAIL_EXPORT const char* dmafail_get_version(void);

/**
 * Get build information string
 * 
 * @return Build info string
 */
LIBDMAFAIL_EXPORT const char* dmafail_get_build_info(void);

/*
 * Error codes
 */
#define DMAFAIL_SUCCESS             0
#define DMAFAIL_ERROR_INIT_FAILED  -1
#define DMAFAIL_ERROR_NOT_SUPPORTED -2
#define DMAFAIL_ERROR_INVALID_ADDR  -3
#define DMAFAIL_ERROR_WRITE_FAILED  -4
#define DMAFAIL_ERROR_HARDWARE      -5

/**
 * Get error string for error code
 * 
 * @param error_code Error code returned by dmafail functions
 * @return Human-readable error string
 */
LIBDMAFAIL_EXPORT const char* dmafail_get_error_string(int error_code);

#ifdef __cplusplus
}
#endif

#endif /* LIBDMAFAIL_H */
