#ifndef LJB_CODESIGN_H
#define LJB_CODESIGN_H

#include <choma/CodeDirectory.h>

#define CS_PLATFORM_BINARY          0x04000000  /* this is a platform binary */

/* csops  operations */
#define	CS_OPS_STATUS		0	/* return status */

int csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize);
int csops_audittoken(pid_t pid, unsigned int ops, void * useraddr, size_t usersize, audit_token_t * token);

#endif
