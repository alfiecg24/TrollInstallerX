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
            printf("[-] Couldn't find file (to): %s", to);
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
            printf("[-] Couldn't find file (from): %s", from);
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
    _offsets_init();
    uint64_t orig_nc_vp = 0;
    uint64_t orig_to_vnode = 0;
    return switch_binary_via_namecache_internal(to, from, &orig_to_vnode, &orig_nc_vp) == 0;
}
