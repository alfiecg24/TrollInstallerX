//
//  libkfd.h
//  libkfd - Standalone kfd kernel exploit library
//
//  Created by Augment Agent on 2025-07-12.
//

#ifndef LIBKFD_H
#define LIBKFD_H

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// Export symbols for dynamic library
#define LIBKFD_EXPORT __attribute__((visibility("default")))

/*
 * kfd exploit methods
 */
typedef enum {
    KFD_PUAF_PHYSPUPPET = 0,
    KFD_PUAF_SMITH = 1,
    KFD_PUAF_LANDA = 2,
} kfd_puaf_method_t;

typedef enum {
    KFD_KREAD_KQUEUE_WORKLOOP_CTL = 0,
    KFD_KREAD_SEM_OPEN = 1,
    KFD_KREAD_IOSURFACE = 2,
} kfd_kread_method_t;

typedef enum {
    KFD_KWRITE_DUP = 0,
    KFD_KWRITE_SEM_OPEN = 1,
    KFD_KWRITE_IOSURFACE = 2,
} kfd_kwrite_method_t;

/*
 * Public API
 */

/**
 * Initialize kfd exploit with specified methods
 * @param puaf_pages Number of PUAF pages (16-3072)
 * @param puaf_method PUAF method to use
 * @param kread_method Kernel read method
 * @param kwrite_method Kernel write method
 * @return kfd handle on success, 0 on failure
 */
LIBKFD_EXPORT uint64_t kfd_open(uint64_t puaf_pages, 
                                kfd_puaf_method_t puaf_method, 
                                kfd_kread_method_t kread_method, 
                                kfd_kwrite_method_t kwrite_method);

/**
 * Read from kernel memory
 * @param kfd kfd handle
 * @param kaddr Kernel address to read from
 * @param uaddr User buffer to read into
 * @param size Number of bytes to read
 */
LIBKFD_EXPORT void kfd_read(uint64_t kfd, uint64_t kaddr, void* uaddr, uint64_t size);

/**
 * Write to kernel memory
 * @param kfd kfd handle
 * @param uaddr User buffer to write from
 * @param kaddr Kernel address to write to
 * @param size Number of bytes to write
 */
LIBKFD_EXPORT void kfd_write(uint64_t kfd, void* uaddr, uint64_t kaddr, uint64_t size);

/**
 * Close kfd handle and cleanup
 * @param kfd kfd handle to close
 */
LIBKFD_EXPORT void kfd_close(uint64_t kfd);

/*
 * Convenience functions for different data sizes
 */
LIBKFD_EXPORT uint8_t kfd_read8(uint64_t kfd, uint64_t kaddr);
LIBKFD_EXPORT uint16_t kfd_read16(uint64_t kfd, uint64_t kaddr);
LIBKFD_EXPORT uint32_t kfd_read32(uint64_t kfd, uint64_t kaddr);
LIBKFD_EXPORT uint64_t kfd_read64(uint64_t kfd, uint64_t kaddr);

LIBKFD_EXPORT void kfd_write8(uint64_t kfd, uint64_t kaddr, uint8_t value);
LIBKFD_EXPORT void kfd_write16(uint64_t kfd, uint64_t kaddr, uint16_t value);
LIBKFD_EXPORT void kfd_write32(uint64_t kfd, uint64_t kaddr, uint32_t value);
LIBKFD_EXPORT void kfd_write64(uint64_t kfd, uint64_t kaddr, uint64_t value);

/**
 * Read buffer from kernel memory
 * @param kfd kfd handle
 * @param kaddr Kernel address to read from
 * @param buffer User buffer to read into
 * @param size Number of bytes to read
 * @return 0 on success, negative on error
 */
LIBKFD_EXPORT int kfd_read_buffer(uint64_t kfd, uint64_t kaddr, void* buffer, size_t size);

/**
 * Write buffer to kernel memory
 * @param kfd kfd handle
 * @param kaddr Kernel address to write to
 * @param buffer User buffer to write from
 * @param size Number of bytes to write
 * @return 0 on success, negative on error
 */
LIBKFD_EXPORT int kfd_write_buffer(uint64_t kfd, uint64_t kaddr, const void* buffer, size_t size);

/*
 * Initialization functions for specific methods
 */
LIBKFD_EXPORT bool kfd_init_physpuppet(void);
LIBKFD_EXPORT bool kfd_init_smith(void);
LIBKFD_EXPORT bool kfd_init_landa(void);
LIBKFD_EXPORT bool kfd_deinit(void);

/*
 * Version information
 */
LIBKFD_EXPORT const char* kfd_get_version(void);
LIBKFD_EXPORT const char* kfd_get_build_info(void);

#ifdef __cplusplus
}
#endif

#endif /* LIBKFD_H */
