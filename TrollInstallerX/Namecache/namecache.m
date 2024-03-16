//
//  namecache.m
//  TrollInstallerX
//
//  Created by Alfie on 13/03/2024.
//

#import <Foundation/Foundation.h>
#import <libjailbreak/util.h>
#import <libjailbreak/primitives.h>

#import "offsets.h"

uint64_t get_vnode_for_file(char* filename) {
    int file_index = open(filename, O_RDONLY);
    if (file_index == -1) return -1;
    
    uint64_t proc = proc_self();
    
    uint64_t filedesc_pac = kread64(proc + off_p_pfd);
    uint64_t filedesc = UNSIGN_PTR(filedesc_pac);
    uint64_t openedfile = kread64(filedesc + (8 * file_index));
    uint64_t fileglob_pac = kread64(openedfile + off_fp_glob);
    uint64_t fileglob = UNSIGN_PTR(fileglob_pac);
    uint64_t vnode_pac = kread64(fileglob + off_fg_data);
    uint64_t vnode = UNSIGN_PTR(vnode_pac);
    
    close(file_index);
    
    return vnode;
}

uint64_t find_child_vnode_by_vnode(uint64_t vnode, char* childname) {
    uint64_t vp_nameptr = kread64(vnode + off_vnode_v_name);
    uint64_t vp_name = kread64(vp_nameptr);
    
    uint64_t vp_namecache = kread64(vnode + off_vnode_v_ncchildren_tqh_first);
    
    if(vp_namecache == 0)
        return 0;
    
    while(1) {
        if(vp_namecache == 0)
            break;
        vnode = kread64(vp_namecache + off_namecache_nc_vp);
        if(vnode == 0)
            break;
        vp_nameptr = kread64(vnode + off_vnode_v_name);
        
        char vp_name[256];
        kreadbuf(vp_nameptr, &vp_name, 256);
        printf("vp_name: %s\n", vp_name);
        
        if(strcmp(vp_name, childname) == 0) {
            return vnode;
        }
        vp_namecache = kread64(vp_namecache + off_namecache_nc_child_tqe_prev);
    }
    
    return 0;
}

uint64_t get_vnode_at_path_by_chdir(char *path) {
    if(access(path, F_OK) == -1)    return -1;
    if(chdir(path) == -1) return -1;
    
    uint64_t fd_cdir_vp = kread64(proc_self() + off_p_pfd + off_fd_cdir);
    chdir("/");
    return fd_cdir_vp;
}

uint64_t switch_binary_via_namecache_internal(char* to, char* from, uint64_t* orig_to_vnode, uint64_t* orig_nc_vp)
{
    uint64_t to_vnode = get_vnode_for_file(to);
    if(to_vnode == -1) {
        NSString *to_dir = [[NSString stringWithUTF8String:to] stringByDeletingLastPathComponent];
        NSString *to_file = [[NSString stringWithUTF8String:to] lastPathComponent];
        uint64_t to_dir_vnode = get_vnode_at_path_by_chdir(to_dir.UTF8String);
        to_vnode = find_child_vnode_by_vnode(to_dir_vnode, to_file.UTF8String);
        if(to_vnode == 0) {
            printf("[-] Couldn't find file (to): %s\n", to);
            return -1;
        }
    }
    
    uint64_t from_vnode = get_vnode_for_file(from);
    if(from_vnode == -1) {
        NSString *from_dir = [[NSString stringWithUTF8String:from] stringByDeletingLastPathComponent];
        NSString *from_file = [[NSString stringWithUTF8String:from] lastPathComponent];
        uint64_t from_dir_vnode = get_vnode_at_path_by_chdir(from_dir.UTF8String);
        from_vnode = find_child_vnode_by_vnode(from_dir_vnode, from_file.UTF8String);
        if(from_vnode == 0) {
            printf("[-] Couldn't find file (from): %s\n", from);
            return -1;
        }
    }
    
    uint64_t to_vnode_nc = kread64(to_vnode + off_vnode_v_nclinks_lh_first);
    *orig_nc_vp = kread64(to_vnode_nc + off_namecache_nc_vp);
    *orig_to_vnode = to_vnode;
    kwrite64(to_vnode_nc + off_namecache_nc_vp, from_vnode);
    return 0;
}

bool switch_file_via_namecache(const char *to, const char *from) {
//    _offsets_init();
    uint64_t orig_nc_vp = 0;
    uint64_t orig_to_vnode = 0;
    return switch_binary_via_namecache_internal(to, from, &orig_to_vnode, &orig_nc_vp) == 0;
}

uint64_t funVnodeUnRedirectFolder (char* to, uint64_t orig_to_v_data) {
    uint64_t to_vnode = get_vnode_at_path_by_chdir(to);
    if(to_vnode == -1) {
        printf("[-] Unable to get vnode, path: %s\n", to);
        return -1;
    }
    
    uint8_t to_v_references = kread8(to_vnode + off_vnode_v_references);
    uint32_t to_usecount = kread32(to_vnode + off_vnode_v_usecount);
    uint32_t to_v_kusecount = kread32(to_vnode + off_vnode_v_kusecount);
    
    kwrite64(to_vnode + off_vnode_v_data, orig_to_v_data);
    
    if(to_usecount > 0)
        kwrite32(to_vnode + off_vnode_v_usecount, to_usecount - 1);
    if(to_v_kusecount > 0)
        kwrite32(to_vnode + off_vnode_v_kusecount, to_v_kusecount - 1);
    if(to_v_references > 0)
        kwrite8(to_vnode + off_vnode_v_references, to_v_references - 1);
    
    return 0;
}

uint64_t funVnodeUnRedirect(uint64_t vnode, uint64_t orig_to_v_data) {
    
    uint8_t to_v_references = kread8(vnode + off_vnode_v_references);
    uint32_t to_usecount = kread32(vnode + off_vnode_v_usecount);
    uint32_t to_v_kusecount = kread32(vnode + off_vnode_v_kusecount);
    
    kwrite64(vnode + off_vnode_v_data, orig_to_v_data);
    
    if(to_usecount > 0)
        kwrite32(vnode + off_vnode_v_usecount, to_usecount - 1);
    if(to_v_kusecount > 0)
        kwrite32(vnode + off_vnode_v_kusecount, to_v_kusecount - 1);
    if(to_v_references > 0)
        kwrite8(vnode + off_vnode_v_references, to_v_references - 1);
    
    return 0;
}

uint64_t funVnodeIterateByVnode(uint64_t vnode) {
    uint64_t vp_nameptr = kread64(vnode + off_vnode_v_name);
    uint64_t vp_name = kread64(vp_nameptr);
    
    printf("[i] vnode->v_name: %s\n", &vp_name);
    
    //get child directory
    uint64_t vp_namecache = kread64(vnode + off_vnode_v_ncchildren_tqh_first);
    printf("[i] vnode->v_ncchildren.tqh_first: 0x%llx\n", vp_namecache);
    if(vp_namecache == 0)
        return 0;
    
    while(1) {
        if(vp_namecache == 0)
            break;
        vnode = kread64(vp_namecache + off_namecache_nc_vp);
        if(vnode == 0)
            break;
        vp_nameptr = kread64(vnode + off_vnode_v_name);
        
        char vp_name[256];
        kreadbuf(vp_nameptr, &vp_name, 256);
        
        printf("[i] vnode->v_name: %s, vnode: 0x%llx\n", vp_name, vnode);
        vp_namecache = kread64(vp_namecache + off_namecache_nc_child_tqe_prev);
    }
    
    return 0;
}
uint64_t funVnodeRedirectFolderFromVnode(char* to, uint64_t from_vnode) {
    uint64_t to_vnode = get_vnode_at_path_by_chdir(to);
    if(to_vnode == -1) {
        printf("[-] Unable to get vnode, path: %s\n", to);
        return -1;
    }
    
    uint8_t to_v_references = kread8(to_vnode + off_vnode_v_references);
    uint32_t to_usecount = kread32(to_vnode + off_vnode_v_usecount);
    uint32_t to_v_kusecount = kread32(to_vnode + off_vnode_v_kusecount);
    uint64_t orig_to_v_data = kread64(to_vnode + off_vnode_v_data);
    
    //If mount point is different, return -1
    uint64_t to_devvp = kread64(UNSIGN_PTR(kread64(to_vnode + off_vnode_v_mount)) + off_mount_mnt_devvp);
    uint64_t from_devvp = kread64(UNSIGN_PTR(kread64(from_vnode + off_vnode_v_mount)) + off_mount_mnt_devvp);
    if(to_devvp != from_devvp) {
        printf("[-] mount points of folders are different - to_devvp=0x%llx, from_devvp=0x%llx!\n", to_devvp, from_devvp);
        return -1;
    }
    
    uint64_t from_v_data = kread64(from_vnode + off_vnode_v_data);
    
    kwrite32(to_vnode + off_vnode_v_usecount, to_usecount + 1);
    kwrite32(to_vnode + off_vnode_v_kusecount, to_v_kusecount + 1);
    kwrite8(to_vnode + off_vnode_v_references, to_v_references + 1);
    kwrite64(to_vnode + off_vnode_v_data, from_v_data);
    
    return orig_to_v_data;
}

uint64_t funVnodeRedirectVnodeFromVnode(uint64_t to_vnode, uint64_t from_vnode) {
    printf("kread #1\n");
    uint8_t to_v_references = kread8(to_vnode + off_vnode_v_references);
    printf("kread #2\n");
    uint32_t to_usecount = kread32(to_vnode + off_vnode_v_usecount);
    printf("kread #3\n");
    uint32_t to_v_kusecount = kread32(to_vnode + off_vnode_v_kusecount);
    printf("kread #4\n");
    uint64_t orig_to_v_data = kread64(to_vnode + off_vnode_v_data);
    
    //If mount point is different, return -1
    printf("kread #5\n");
    uint64_t to_devvp = kread64((kread64(to_vnode + off_vnode_v_mount) | 0xffffff8000000000) + off_mount_mnt_devvp);
    printf("kread #6\n");
    uint64_t from_devvp = kread64((kread64(from_vnode + off_vnode_v_mount) | 0xffffff8000000000) + off_mount_mnt_devvp);
    if(to_devvp != from_devvp) {
        printf("[-] mount points of folders are different - to_devvp=0x%llx, from_devvp=0x%llx!\n", to_devvp, from_devvp);
        return -1;
    }
    
    printf("kread #7\n");
    uint64_t from_v_data = kread64(from_vnode + off_vnode_v_data);
    
    printf("kwrite #1\n");
    kwrite32(to_vnode + off_vnode_v_usecount, to_usecount + 1);
    printf("kwrite #2\n");
    kwrite32(to_vnode + off_vnode_v_kusecount, to_v_kusecount + 1);
    printf("kwrite #3\n");
    kwrite8(to_vnode + off_vnode_v_references, to_v_references + 1);
    printf("kwrite #4\n");
    kwrite64(to_vnode + off_vnode_v_data, from_v_data);
    
    printf("ALL DONE!\n");
    return orig_to_v_data;
}

uint64_t get_vnode_at_path(char* filename) {
    int file_index = open(filename, O_RDONLY);
    if (file_index == -1) return -1;
    
    uint64_t proc = proc_self();

    uint64_t filedesc_pac = kread64(proc + off_p_pfd);
    uint64_t filedesc = UNSIGN_PTR(filedesc_pac);
    uint64_t openedfile = kread64(filedesc + (8 * file_index));
    uint64_t fileglob_pac = kread64(openedfile + off_fp_glob);
    uint64_t fileglob = UNSIGN_PTR(fileglob_pac);
    uint64_t vnode_pac = kread64(fileglob + off_fg_data);
    uint64_t vnode = UNSIGN_PTR(vnode_pac);
    
    close(file_index);
    
    return vnode;
}


#include <sys/stat.h>
uint64_t funVnodeChown(const char* filename, uid_t uid, gid_t gid) {

    uint64_t vnode = get_vnode_at_path(filename);
    if(vnode == -1) {
        printf("[-] Unable to get vnode, path: %s\n", filename);
        return -1;
    }
    
    uint64_t v_data = kread64(vnode + off_vnode_v_data);
    uint32_t v_uid = kread32(v_data + 0x80);
    uint32_t v_gid = kread32(v_data + 0x84);
    //vnode->v_data->uid
    printf("[i] Patching %s vnode->v_uid %d -> %d\n", filename, v_uid, uid);
    kwrite32(v_data+0x80, uid);
    //vnode->v_data->gid
    printf("[i] Patching %s vnode->v_gid %d -> %d\n", filename, v_gid, gid);
    kwrite32(v_data+0x84, gid);
    
    struct stat file_stat;
    if(stat(filename, &file_stat) == 0) {
        printf("[+] %s UID: %d\n", filename, file_stat.st_uid);
        printf("[+] %s GID: %d\n", filename, file_stat.st_gid);
    }
    
    return 0;
}

uint64_t funVnodeChown2(uint64_t vnode, uid_t uid, gid_t gid) {
    
    uint64_t v_data = kread64(vnode + off_vnode_v_data);
    uint32_t v_uid = kread32(v_data + 0x80);
    uint32_t v_gid = kread32(v_data + 0x84);
    //vnode->v_data->uid
    printf("[i] Patching vnode->v_uid %d -> %d\n", v_uid, uid);
    kwrite32(v_data+0x80, uid);
    //vnode->v_data->gid
    printf("[i] Patching vnode->v_gid %d -> %d\n", v_gid, gid);
    kwrite32(v_data+0x84, gid);
    
    return 0;
}
uint64_t funVnodeChmod(const char* filename, mode_t mode) {
    
    _offsets_init();
    uint64_t vnode = get_vnode_at_path(filename);
    if(vnode == -1) {
        printf("[-] Unable to get vnode, path: %s\n", filename);
        return -1;
    }
    
    printf("path: %s\n", filename);
    
    uint64_t v_data = kread64(vnode + off_vnode_v_data);
    uint32_t v_mode = kread32(v_data + 0x88);
    
    printf("[i] Patching %s vnode->v_mode %o -> %o\n", filename, v_mode, mode);
    kwrite32(v_data+0x88, mode);
    
    struct stat file_stat;
    if(stat(filename, &file_stat) == 0) {
        printf("[+] %s mode: %o\n", filename, file_stat.st_mode);
    }
    
    return 0;
}

void tests(void) {
    _offsets_init();
    printf("Let's do this\n");
//    sleep(5);
    uint64_t var_vnode = get_vnode_at_path_by_chdir("/private/var");
    uint64_t var_containers_vnode = find_child_vnode_by_vnode(var_vnode, "containers");
    uint64_t var_containers_bundle_vnode = find_child_vnode_by_vnode(var_containers_vnode, "Bundle");
    uint64_t var_containers_bundle_application_vnode = find_child_vnode_by_vnode(var_containers_bundle_vnode, "Application");
    sleep(1);
    
    NSString *mntPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Documents/mounted"];
    uint64_t dest_vnode = get_vnode_at_path_by_chdir(mntPath.UTF8String);
    [[NSFileManager defaultManager] removeItemAtPath:mntPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:mntPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    
    uint64_t orig_to_v_data = funVnodeRedirectVnodeFromVnode(dest_vnode, var_containers_bundle_application_vnode);
    printf("orig_to_v_data: 0x%llx\n", orig_to_v_data);
//    sleep(1);
    
    funVnodeChown2(var_containers_bundle_application_vnode, 501, 501);
    
    NSError *error;
    [@"TROLLINSTALLERX WE OUT HERE!!!!" writeToFile:[mntPath stringByAppendingString:@"/.trollinstallerx"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        printf("ERROR: NO FILE WRITE!!!\n");
    }
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mntPath error:NULL];
    NSLog(@"mntPath directory list: %@", dirs);
    
    // Restore original owner/group
    funVnodeChown2(var_containers_bundle_application_vnode, 33, 33);
    
//    sleep(10);
    
    funVnodeUnRedirect(dest_vnode, orig_to_v_data);
}
