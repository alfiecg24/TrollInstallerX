//
//  grabkernel.c
//  TrollInstallerX
//
//  Created by Alfie on 14/02/2024.
//

#include "grabkernel.h"
#include <Foundation/Foundation.h>
#include <libfragmentzip/libfragmentzip.h>
#include <string.h>
#include <sys/sysctl.h>
#include "appledb.h"

static NSString *getBoardconfig(void) {
    char boardconfig[256];
    size_t size = sizeof(boardconfig);
    int result = sysctlbyname("hw.target", &boardconfig, &size, NULL, 0);
    if (result) {
        return nil;
    }

    return [NSString stringWithCString:boardconfig encoding:NSUTF8StringEncoding];
}

bool download_kernelcache(NSString *zipURL, bool isOTA, NSString *outDir) {
    NSError *error = nil;
    NSString *pathPrefix = isOTA ? @"AssetData/boot" : @"";
    NSString *boardconfig = getBoardconfig();

    fragmentzip_t *fz = NULL;

    fz = fragmentzip_open(zipURL.UTF8String);
    if (!fz) {
        printf("Failed to open fragment zip handle!\n");
        return false;
    }

    printf("Downloading BuildManifest.plist...\n");

    char *buildManifestRaw = NULL;
    size_t buildManifestRawSize = 0;

    if (fragmentzip_download_to_memory(fz, [pathPrefix stringByAppendingPathComponent:@"BuildManifest.plist"].UTF8String, &buildManifestRaw,
                                       &buildManifestRawSize, NULL)) {
        printf("Failed to download BuildManifest.plist!\n");
        fragmentzip_close(fz);
        return false;
    }

    NSData *buildManifestData = [NSData dataWithBytesNoCopy:buildManifestRaw length:buildManifestRawSize];
    NSDictionary *buildManifest = [NSPropertyListSerialization propertyListWithData:buildManifestData options:0 format:NULL error:&error];
    if (error) {
        printf("Failed to parse BuildManifest.plist!\n");
        fragmentzip_close(fz);
        return false;
    }

    NSString *kernelCachePath = nil;

    for (NSDictionary<NSString *, id> *identity in buildManifest[@"BuildIdentities"]) {
        if ([identity[@"Info"][@"Variant"] hasPrefix:@"Research"]) {
            continue;
        }
        if ([identity[@"Info"][@"DeviceClass"] isEqualToString:boardconfig.lowercaseString]) {
            kernelCachePath = [pathPrefix stringByAppendingPathComponent:identity[@"Manifest"][@"KernelCache"][@"Info"][@"Path"]];
        }
    }

    if (!kernelCachePath) {
        printf("Failed to find kernelcache path in BuildManifest.plist!\n");
        fragmentzip_close(fz);
        return false;
    }

    NSString *kernelCacheOut = [outDir stringByAppendingPathComponent:@"kernelcache"];
    printf("Downloading %s...\n", kernelCachePath.UTF8String);

    if (fragmentzip_download_file(fz, kernelCachePath.UTF8String, kernelCacheOut.UTF8String, NULL) != 0) {
        printf("Failed to download %s!\n", kernelCachePath.UTF8String);
        fragmentzip_close(fz);
        return false;
    }

    fragmentzip_close(fz);

    return true;
}

bool grab_kernelcache(NSString *outDir) {
    NSString *boardconfig = getBoardconfig();
    if (!boardconfig) {
        printf("Failed to get boardconfig!\n");
        return false;
    }

    bool isOTA = NO;
    NSString *firmwareURL = getFirmwareURL(&isOTA);
    if (!firmwareURL) {
        printf("Failed to get firmware URL!\n");
        return false;
    }

    return download_kernelcache(firmwareURL, isOTA, outDir);
}
