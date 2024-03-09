//
//  install.m
//  TrollInstallerX
//
//  Created by Alfie on 09/03/2024.
//

#import <Foundation/Foundation.h>
#include <libjailbreak/util.h>
#include "TSUtil.h"

#include "install.h"

// https://github.com/opa334/TrollStore/releases/latest/download/TrollStore.tar

// Install TrollStore
bool install_trollstore(NSString *helper, NSString *tar) {
    NSString *stdout;
    int ret = spawnRoot(helper, @[@"install-trollstore", tar], &stdout, NULL);
    printf("trollstorehelper output: %s\n", [stdout UTF8String]);
    return ret == 0;
}
