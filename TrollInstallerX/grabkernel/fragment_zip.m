//
//  fragment_zip.c
//  TrollInstallerX
//
//  Created by Alfie on 14/02/2024.
//

#include "fragment_zip.h"
#include <libfragmentzip/libfragmentzip.h>
#include <string.h>

int download_manifest(const char *zipURL, const char *outDir) {
    
    fragmentzip_t *fz = NULL;
    
    fz = fragmentzip_open(zipURL);
    if (!fz) {
        printf("Failed to open fragment zip handle!\n");
        return -1;
    }
    
    char *path = malloc(strlen(outDir) + strlen("/BuildManifest.plist") + 1);
    strcpy(path, outDir);
    strcat(path, "/BuildManifest.plist");
    
    printf("Downloading BuildManifest.plist...\n");
    
    if (fragmentzip_download_file(fz, "BuildManifest.plist", path, NULL) != 0) {
        printf("Failed to download BuildManifest.plist!\n");
        return -1;
    }
    
    fragmentzip_close(fz);
    
    return 0;
}


int download_kernelcache(const char *zipURL, const char *fileName, const char *outDir) {
    
    fragmentzip_t *fz = NULL;
    
    fz = fragmentzip_open(zipURL);
    if (!fz) {
        printf("Failed to open fragment zip handle!\n");
        return -1;
    }
    
    char *path = malloc(strlen(outDir) + strlen("/kernelcache") + 1);
    strcpy(path, outDir);
    strcat(path, "/kernelcache");
    
    printf("Downloading %s...\n", fileName);
    
    if (fragmentzip_download_file(fz, fileName, path, NULL) != 0) {
        printf("Failed to download %s!\n", fileName);
        return -1;
    }
    
    fragmentzip_close(fz);
    
    return 0;
}
