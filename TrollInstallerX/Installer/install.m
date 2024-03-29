//
//  install.m
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

#import <Foundation/Foundation.h>

#import <spawn.h>
#import <sys/stat.h>

#import "run.h"

// Install TrollStore
bool install_trollstore(NSString *tar) {
    NSString *stdout;
    NSString *helperPath = @"/private/preboot/tmp/trollstorehelper";
    chmod(helperPath.UTF8String, 0755);
    chown(helperPath.UTF8String, 0, 0);
    int ret = run_as_root(helperPath, @[@"install-trollstore", tar], &stdout);
    printf("trollstorehelper output: %s\n", [stdout UTF8String]);
    return ret == 0;
}

NSString *find_path_for_app(NSString *appName) {
    // Go through /var/containers/Bundle/Application
    // Look inside every folder for TrollStore.app
    // If we get a match, return $PATH_TO_TROLLSTORE_APP/trollstorehelper

    // Hacky, but it works
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bundlePath = @"/var/containers/Bundle/Application";
    NSArray *bundleContents = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];

    for (NSString *bundle in bundleContents) {
        NSString *bundleFullPath = [bundlePath stringByAppendingPathComponent:bundle];
        NSString *bundleFullPathWithApp = [bundleFullPath stringByAppendingPathComponent:appName];
        NSString *trollStorePath = [bundleFullPathWithApp stringByAppendingString:@".app"];
        if ([fileManager fileExistsAtPath:trollStorePath]) {
            NSString *trollStoreHelperPath = [trollStorePath stringByAppendingPathComponent:@"trollstorehelper"];
            if ([fileManager fileExistsAtPath:trollStoreHelperPath]) {
                return trollStoreHelperPath;
            }
        }
    }
    
    return nil;
}

bool uicache(void) {
    NSString *stdout;
    NSString *helperPath = find_path_for_app(@"TrollStore");
    if (helperPath == nil) {
        printf("Failed to find trollstorehelper\n");
        return false;
    }
    NSLog(@"Found trollstorehelper at %@", helperPath);
    int ret = run_as_root(helperPath, @[@"refresh-all"], &stdout);
    
    printf("trollstorehelper output: %s\n", [stdout UTF8String]);
    return ret == 0;
}
