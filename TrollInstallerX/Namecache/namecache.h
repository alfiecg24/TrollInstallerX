//
//  namecache.h
//  TrollInstallerX
//
//  Created by Alfie on 13/03/2024.
//

#ifndef namecache_h
#define namecache_h

bool switch_file_via_namecache(const char *to, const char *from);
void tests(void);
uint64_t funVnodeChmod(const char* filename, mode_t mode);
uint64_t funVnodeChown(const char* filename, uid_t uid, gid_t gid);

#endif /* namecache_h */
