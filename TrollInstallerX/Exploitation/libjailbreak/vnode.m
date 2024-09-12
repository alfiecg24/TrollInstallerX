//
//  vnode.m
//  TrollInstallerX
//
//  Created by Alfie on 01/04/2024.
//

#import <Foundation/Foundation.h>
#import "vnode.h"
#import "util.h"
#import "primitives.h"

uint64_t get_vnode_for_path(const char *path) {
    int fd = open(path, O_RDONLY);
    if (fd == -1) return -1;
    
    uint64_t proc = proc_self();
    uint64_t filedesc = UNSIGN_PTR(kread64(proc + 0xF8)); // proc->filedesc
    uint64_t openedFile = kread64(filedesc + (8 * fd)); // filedesc.files[index]
    uint64_t fileglob = UNSIGN_PTR(kread64(openedFile + 0x10)); // filedesc.files[index]->fileglob
    uint64_t vnode = UNSIGN_PTR(kread64(fileglob + 0x38)); // fileglob->vnode
    
    close(fd);
    return vnode;
}

uint64_t get_vnode_for_path_by_chdir(const char *path) {
    if (access(path, F_OK) == -1) {
        return -1;
    }
    if (chdir(path) == -1) { return -1; }
    
    uint64_t fd_cdir_vp = kread64(proc_self() + 0xF8 + 0x20); // proc->p_pfd->fd_cdir
    chdir("/");
    return fd_cdir_vp;
}

uint64_t get_child_vnode_from_vnode(uint64_t vnode, const char *file) {
    uint64_t vp_nameptr = kread64(vnode + 0xB8); // vnode->vp_name
    uint64_t vp_namecache = kread64(vnode + 0x30); // vnode->v_ncchildren_tqh_first
    if (vp_namecache == 0) {
        printf("vp_namecache is 0!\n");
        return -1;
    }
    
    while (1) {
        if (vp_namecache == 0) {
            break;
        }
        vnode = kread64(vp_namecache + 0x48); // vp_namecache->nc_vp
        if (vnode == 0) {
            break;
        }
        vp_nameptr = kread64(vnode + 0xB8);
        
        char vp_name[16];
        kreadbuf(kread64(vp_namecache + 0x60), &vp_name, 16);
        
        printf("File: %s\n", vp_name);
        
        if (strcmp(vp_name, file) == 0) {
            printf("Found %s!\n", vp_name);
            return vnode;
        }
    }
    return vnode;
}

bool vnode_chown(uint64_t vnode, uid_t uid, gid_t gid) {
    uint64_t v_data = kread64(vnode + 0xE0); // vnode->v_data
    uint32_t v_uid = kread32(v_data + 0x80); // vnode->v_uid
    uint32_t v_gid = kread32(v_data + 0x84); // vnode->v_gid
    
//    printf("vnode->v_uid %d -> %d\n", v_uid, uid);
    kwrite32(v_data + 0x80, uid);
//    printf("vnode->v_gid %d -> %d\n", v_gid, gid);
    kwrite32(v_data + 0x84, gid);
    
    return kread32(v_data + 0x80) == uid
    && kread32(v_data + 0x84) == gid;
}

bool vnode_chmod(uint64_t vnode, mode_t mode) {
    uint64_t v_data = kread64(vnode + 0xE0); // vnode->v_data
    uint32_t v_mode = kread32(v_data + 0x88); // vnode->v_data.v_mode
    
//    printf("vnode->v_mode %o -> %o\n", v_mode, mode);
    kwrite32(v_data + 0x88, mode);
    
    return kread32(v_data + 0x88) == mode;
}

uint64_t vnode_redirect_folder(const char *to, const char *from) {
    
    uint64_t to_vnode = get_vnode_for_path_by_chdir(to);
    if (to_vnode == -1) {
        printf("Failed to get vnode for %s\n", to);
        return false;
    }
    
    uint64_t orig_to_v_data = kread64(to_vnode + 0xE0); // vnode->v_data
    
    uint64_t from_vnode = get_vnode_for_path_by_chdir(from);
    if (from_vnode == -1) {
        printf("Failed to get vnode for %s\n", from);
        return -1;
    }
    
    uint64_t from_v_data = kread64(from_vnode + 0xE0);
    
    kwrite64(to_vnode + 0xE0, from_v_data);
    
    vnode_chown(from_vnode, 501, 501);
    vnode_chown(to_vnode, 501, 501);
    usleep(2000);
    return orig_to_v_data;
}

bool vnode_unredirect_folder(const char *folder, uint64_t orig) {
    uint64_t vnode = get_vnode_for_path_by_chdir(folder);
    if (vnode == -1) { return false; }
    
    kwrite64(vnode + 0xE0, orig); // vnode->v_data
    
    return true;
}

NSArray *get_installed_apps(void) {
    NSString *mountPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mount"];
    [[NSFileManager defaultManager] removeItemAtPath:mountPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:mountPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    // Redirect bundle path to our mount directory
    uint64_t orig_to_v_data = vnode_redirect_folder(mountPath.UTF8String, "/var/containers/Bundle/Application");
    if (orig_to_v_data == -1) {
        printf("Failed to redirect folder!\n");
        return nil;
    }
    
    NSMutableArray *apps = [NSMutableArray array];
    
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mountPath error:nil];
    vnode_unredirect_folder(mountPath.UTF8String, orig_to_v_data);
    
    for (NSString *uuid in folderContents) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", @"/var/containers/Bundle/Application", uuid];
        orig_to_v_data = vnode_redirect_folder(mountPath.UTF8String, fullPath.UTF8String);
        
        NSArray *uuidFolderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mountPath error:nil];
        vnode_unredirect_folder(mountPath.UTF8String, orig_to_v_data);
        
        for (NSString *item in uuidFolderContents) {
            if ([item hasSuffix:@".app"]) {
                NSString *partialPath = [NSString stringWithFormat:@"%@/%@", uuid, item];
                [apps addObject:partialPath];
            }
        }
    }
    
    return apps;
}

bool is_persistence_helper_installed(const char **pathOut) {
    NSString *mountPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mount"];
    [[NSFileManager defaultManager] removeItemAtPath:mountPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:mountPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    // Redirect bundle path to our mount directory
    uint64_t orig_to_v_data = vnode_redirect_folder(mountPath.UTF8String, "/var/containers/Bundle/Application");
    if (orig_to_v_data == -1) {
        printf("Failed to redirect folder!\n");
        return nil;
    }
    
    bool foundPersistenceHelper = false;
    
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mountPath error:nil];
    vnode_unredirect_folder(mountPath.UTF8String, orig_to_v_data);
    
    for (NSString *uuid in folderContents) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", @"/var/containers/Bundle/Application", uuid];
        orig_to_v_data = vnode_redirect_folder(mountPath.UTF8String, fullPath.UTF8String);
        
        NSArray *uuidFolderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mountPath error:nil];
        vnode_unredirect_folder(mountPath.UTF8String, orig_to_v_data);
        
        for (NSString *item in uuidFolderContents) {
            if ([item hasSuffix:@".app"]) {
                NSString *fullBundlePath = [NSString stringWithFormat:@"%@/%@", fullPath, item];
                orig_to_v_data = vnode_redirect_folder(mountPath.UTF8String, fullBundlePath.UTF8String);
                NSArray *appFolderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mountPath error:nil];
                vnode_unredirect_folder(mountPath.UTF8String, orig_to_v_data);
                for (NSString *file in appFolderContents) {
                    if ([file  isEqual: @".TrollStorePersistenceHelper"]) {
                        *pathOut = [item UTF8String];
                        foundPersistenceHelper = true;
                        goto out;
                    }
                }
            }
        }
    }
    out:
    return foundPersistenceHelper;
}

bool install_persistence_helper_via_vnode(const char *bundlePath) {
    
    printf("Installing persistence helper into %s\n", bundlePath);
    
    NSString *mountPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Documents/mount"];
    [[NSFileManager defaultManager] removeItemAtPath:mountPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:mountPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *filePath = [NSString stringWithUTF8String:bundlePath];
    NSString *appBundleName = [filePath lastPathComponent];
    NSString *appName = [appBundleName stringByDeletingPathExtension];
    
    // Redirect bundle path to our mount directory
    uint64_t orig = vnode_redirect_folder(mountPath.UTF8String, bundlePath);
    if (orig == -1) {
        printf("Failed to redirect folder!\n");
        return false;
    }
    
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mountPath error:nil];
    NSLog(@"Contents of bundle: %@", items);
    
    NSString *binary = [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @"Documents", @"PersistenceHelper"];
    NSString *rootHelperOrig = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Documents/trollstorehelper"];
    NSString *dotFileOrig = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Documents/.TrollStorePersistenceHelper"];
    
    /*
     
     App.app/
     App
     * App_TROLLSTORE_BACKUP
     * .TrollStorePersistenceHelper
     * trollstorehelper
     
     * = new file
     
     */
    
    bool ret = false;
    
    NSString *appExecutable = [NSString stringWithFormat:@"%@/%@", mountPath, appName];
    NSString *backup = [NSString stringWithFormat:@"%@/%@_TROLLSTORE_BACKUP", mountPath, appName];
    NSString *dotFile = [NSString stringWithFormat:@"%@/%@", mountPath, @".TrollStorePersistenceHelper"];
    NSString *rootHelper = [NSString stringWithFormat:@"%@/%@", mountPath, @"trollstorehelper"];
    
    uint64_t main_executable = get_vnode_for_path_by_chdir(appExecutable.UTF8String);
    if (main_executable == -1) {
        main_executable = get_vnode_for_path(appExecutable.UTF8String);
        if (main_executable == -1) {
            printf("Could not get executable for %s\n", appExecutable.UTF8String);
            vnode_unredirect_folder(mountPath.UTF8String, orig);
            return ret;
        }
    }
    printf("chown'ing %s (501/501)\n", appExecutable.UTF8String);
    vnode_chown(main_executable, 501, 501);
    
    
    // Create App_TROLLSTORE_BACKUP and trollstorehelper
    printf("Copying %s -> %s\n", appExecutable.UTF8String, backup.UTF8String);
    [[NSFileManager defaultManager] copyItemAtPath:appExecutable toPath:backup error:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:backup]) {
        printf("Could not create backup of executable\n");
        vnode_unredirect_folder(mountPath.UTF8String, orig);
        return ret;
    }
    
    // Create .TrollStorePersistenceHelper
    // HACK - needed for some apps otherwise it panics
    NSString *content = @"TROLLTROLL";
    NSData *fileContent = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:dotFileOrig contents:fileContent attributes:nil];
    printf("Copying %s\n", dotFile.UTF8String);
    [[NSFileManager defaultManager] copyItemAtPath:dotFileOrig toPath:dotFile error:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dotFile]) {
        printf("Could not create dot file\n");
        vnode_unredirect_folder(mountPath.UTF8String, orig);
        return ret;
    }
    
    printf("Copying %s -> %s\n", rootHelperOrig.UTF8String, rootHelper.UTF8String);
    [[NSFileManager defaultManager] copyItemAtPath:rootHelperOrig toPath:rootHelper error:nil];
    
    // Replace with persistence helper
    printf("Removing %s\n", appExecutable.UTF8String);
    [[NSFileManager defaultManager] removeItemAtPath:appExecutable error:nil];
    usleep(1000);
    printf("Copying %s -> %s\n", binary.UTF8String, appExecutable.UTF8String);
    [[NSFileManager defaultManager] copyItemAtPath:binary toPath:appExecutable error:nil];
    
    printf("chown'ing %s (33/33)\n", appExecutable.UTF8String);
    ret = true;
    vnode_unredirect_folder(mountPath.UTF8String, orig);
    return ret;
}
