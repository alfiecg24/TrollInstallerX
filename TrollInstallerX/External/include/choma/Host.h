#ifndef HOST_H
#define HOST_H

#include "FAT.h"

#define CPU_SUBTYPE_ARM64E_ABI_V2 0x80000000

int host_get_cpu_information(cpu_type_t *cputype, cpu_subtype_t *cpusubtype);

// Retrieve the preferred MachO slice from a FAT
// Preferred slice as in the slice that the kernel would use when loading the file
MachO *fat_find_preferred_slice(FAT *fat);

#endif // HOST_H