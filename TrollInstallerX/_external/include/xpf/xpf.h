#include <stdint.h>

#include <choma/FAT.h>
#include <choma/Util.h>
#include <choma/PatchFinder.h>
#include <choma/PatchFinder_arm64.h>
#include <choma/arm64.h>
#include <xpc/xpc.h>

typedef struct s_XPFItem {
	struct s_XPFItem *nextItem;
	const char *name;
	uint64_t (*finder)(void *);
	void *ctx;
	bool cached;
	uint64_t cache;
} XPFItem;

typedef struct s_XPFSet {
	const char *name;
	bool (*supported)(void);
	const char *metrics[];
} XPFSet;

int xpf_start_with_kernel_path(const char *kernelPath);
void xpf_item_register(const char *name, void *finder, void *ctx);
uint64_t xpf_item_resolve(const char *name);
uint64_t xpfsec_read_ptr(PFSection *section, uint64_t vmaddr);
bool xpf_set_is_supported(const char *name);
int xpf_offset_dictionary_add_set(xpc_object_t xdict, XPFSet *set);
xpc_object_t xpf_construct_offset_dictionary(const char *sets[]);
void xpf_set_error(const char *error, ...);
const char *xpf_get_error(void);
void xpf_print_all_items(void);
void xpf_stop(void);

typedef struct s_XPF {
	int kernelFd;
	void *mappedKernel;
	size_t kernelSize;
	void *decompressedKernel;
	size_t decompressedKernelSize;

	FAT *kernelContainer;
	MachO *kernel;
	bool kernelIsFileset;
	bool kernelIsArm64e;
	char *kernelVersionString;
	char *kernelInfoPlist;
	char *darwinVersion;
	char *xnuBuild;
	char *xnuPlatform;
	char *osVersion;

	uint64_t kernelBase;
	uint64_t kernelEntry;

	PFSection *kernelTextSection;
	PFSection *kernelPPLTextSection;
	PFSection *kernelStringSection;
	PFSection *kernelConstSection;
	PFSection *kernelDataConstSection;
	PFSection *kernelDataSection;
	PFSection *kernelOSLogSection;
	PFSection *kernelPrelinkTextSection;
	PFSection *kernelPLKTextSection;
	PFSection *kernelBootdataInit;
	PFSection *kernelAMFITextSection;
	PFSection *kernelAMFIStringSection;
	PFSection *kernelSandboxTextSection;
	PFSection *kernelSandboxStringSection;
	PFSection *kernelInfoPlistSection;

	XPFItem *firstItem;
} XPF;
extern XPF gXPF;
