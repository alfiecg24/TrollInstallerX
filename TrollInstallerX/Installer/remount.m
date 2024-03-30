//
//  remount.m
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

#import <Foundation/Foundation.h>
#import <sys/stat.h>

#import "run.h"

int remount_private_preboot_internal(void) {
    return run_binary(@"/sbin/mount", @[@"-u", @"-w", @"/private/preboot"], nil);
}

bool remount_private_preboot(void) {
    // Only remount if we are on iOS 15 or below
    if (@available(iOS 16, *)) {
        // Do nothing
    } else {
        int ret = remount_private_preboot_internal();
        if (ret != 0) {
            printf("Failed to remount /private/preboot\n");
            return false;
        }
    }
    return true;
}
