//
//  find.m
//  TrollInstallerX
//
//  Created by Alfie on 17/03/2024.
//

#import <Foundation/Foundation.h>

NSString *find_trollstore_helper_path(void) {
    // Go through /var/containers/Bundle/Application
    // Look inside every folder for TrollStore.app
    // If we get a match, return $PATH_TO_TROLLSTORE_APP/trollstorehelper

    // Hacky, but it works
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bundlePath = @"/var/containers/Bundle/Application";
    NSArray *bundleContents = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];

    for (NSString *bundle in bundleContents) {
        NSString *bundleFullPath = [bundlePath stringByAppendingPathComponent:bundle];
        NSString *trollStorePath = [bundleFullPath stringByAppendingPathComponent:@"TrollStore.app"];
        if ([fileManager fileExistsAtPath:trollStorePath]) {
            NSString *trollStoreHelperPath = [trollStorePath stringByAppendingPathComponent:@"trollstorehelper"];
            if ([fileManager fileExistsAtPath:trollStoreHelperPath]) {
                return trollStoreHelperPath;
            }
        }
    }
    
    return nil;
}
