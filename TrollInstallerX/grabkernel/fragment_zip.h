//
//  fragment_zip.h
//  TrollInstallerX
//
//  Created by Alfie on 14/02/2024.
//

#ifndef fragment_zip_h
#define fragment_zip_h

#include <stdio.h>

int download_manifest(const char *zipURL, const char *outDir);
int download_kernelcache(const char *zipURL, const char *fileName, const char *outDir);

#endif /* fragment_zip_h */
