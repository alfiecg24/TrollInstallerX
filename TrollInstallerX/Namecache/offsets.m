//
//  offsets.c
//  kfd
//
//  Created by Seo Hyun-gyu on 2023/07/29.
//

#include "offsets.h"
#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>

uint32_t off_p_list_le_prev = 0;
uint32_t off_p_proc_ro = 0;
uint32_t off_p_ppid = 0;
uint32_t off_p_original_ppid = 0;
uint32_t off_p_pgrpid = 0;
uint32_t off_p_uid = 0;
uint32_t off_p_gid = 0;
uint32_t off_p_ruid = 0;
uint32_t off_p_rgid = 0;
uint32_t off_p_svuid = 0;
uint32_t off_p_svgid = 0;
uint32_t off_p_sessionid = 0;
uint32_t off_p_puniqueid = 0;
uint32_t off_p_pid = 0;
uint32_t off_p_pfd = 0;
uint32_t off_p_textvp = 0;
uint32_t off_p_name = 0;
uint32_t off_p_ro_p_csflags = 0;
uint32_t off_p_ro_p_ucred = 0;
uint32_t off_p_ro_pr_proc = 0;
uint32_t off_p_ro_pr_task = 0;
uint32_t off_p_ro_t_flags_ro = 0;
uint32_t off_u_cr_label = 0;
uint32_t off_u_cr_posix = 0;
uint32_t off_cr_uid = 0;
uint32_t off_cr_ruid = 0;
uint32_t off_cr_svuid = 0;
uint32_t off_cr_ngroups = 0;
uint32_t off_cr_groups = 0;
uint32_t off_cr_rgid = 0;
uint32_t off_cr_svgid = 0;
uint32_t off_cr_gmuid = 0;
uint32_t off_cr_flags = 0;
uint32_t off_task_t_flags = 0;
uint32_t off_task_itk_space = 0;
uint32_t off_fd_ofiles = 0;
uint32_t off_fd_cdir = 0;
uint32_t off_fp_glob = 0;
uint32_t off_fg_data = 0;
uint32_t off_fg_flag = 0;
uint32_t off_vnode_v_ncchildren_tqh_first = 0;
uint32_t off_vnode_v_ncchildren_tqh_last = 0;
uint32_t off_vnode_v_nclinks_lh_first = 0;
uint32_t off_vnode_v_iocount = 0;
uint32_t off_vnode_v_usecount = 0;
uint32_t off_vnode_v_flag = 0;
uint32_t off_vnode_v_name = 0;
uint32_t off_vnode_v_mount = 0;
uint32_t off_vnode_v_data = 0;
uint32_t off_vnode_v_kusecount = 0;
uint32_t off_vnode_v_references = 0;
uint32_t off_vnode_v_lflag = 0;
uint32_t off_vnode_v_owner = 0;
uint32_t off_vnode_v_parent = 0;
uint32_t off_vnode_v_label = 0;
uint32_t off_vnode_v_cred = 0;
uint32_t off_vnode_v_writecount = 0;
uint32_t off_vnode_v_type = 0;
uint32_t off_vnode_v_id = 0;
uint32_t off_vnode_vu_ubcinfo = 0;
uint32_t off_mount_mnt_data = 0;
uint32_t off_mount_mnt_fsowner = 0;
uint32_t off_mount_mnt_fsgroup = 0;
uint32_t off_mount_mnt_devvp = 0;
uint32_t off_mount_mnt_flag = 0;
uint32_t off_specinfo_si_flags = 0;
uint32_t off_namecache_nc_dvp = 0;
uint32_t off_namecache_nc_vp = 0;
uint32_t off_namecache_nc_hashval = 0;
uint32_t off_namecache_nc_name = 0;
uint32_t off_namecache_nc_child_tqe_prev = 0;
uint32_t off_ipc_space_is_table = 0;
uint32_t off_ubc_info_cs_blobs = 0;
uint32_t off_ubc_info_cs_add_gen = 0;
uint32_t off_cs_blob_csb_pmap_cs_entry = 0;
uint32_t off_cs_blob_csb_cdhash = 0;
uint32_t off_cs_blob_csb_flags = 0;
uint32_t off_cs_blob_csb_teamid = 0;
uint32_t off_cs_blob_csb_validation_category = 0;
uint32_t off_pmap_cs_code_directory_ce_ctx = 0;
uint32_t off_pmap_cs_code_directory_der_entitlements_size = 0;
uint32_t off_pmap_cs_code_directory_trust = 0;
uint32_t off_ipc_entry_ie_object = 0;
uint32_t off_ipc_object_io_bits = 0;
uint32_t off_ipc_object_io_references = 0;
uint32_t off_ipc_port_ip_kobject = 0;

uint64_t off_gphysbase = 0;
uint64_t off_gphysize = 0;
uint64_t off_gvirtbase = 0;
uint64_t off_ptov__table = 0;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

void _offsets_init(void) {
    if (!(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"16.0") && SYSTEM_VERSION_LESS_THAN(@"16.7"))) {
        printf("[-] Only supported offset for iOS 16.0-16.6.1\n");
        exit(EXIT_FAILURE);
    }
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/proc_ro.h#L59
    //should be same 16.0~16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_p_ro_p_csflags = 0x1c;
    off_p_ro_p_ucred = 0x20;    //_proc_ucred
    off_p_ro_pr_proc = 0;
    off_p_ro_pr_task = 0x8;
    off_p_ro_t_flags_ro = 0x78;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/osfmk/kern/task.h#L280
    //should be same 16.0~16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_task_itk_space = 0x300; //14p 16.1.2 _task_suspend FFFFFFF007DB43BC
    off_task_t_flags = 0x3D0;   //14p 16.1.2 _get_bsdtask_info FFFFFFF007DE4E60
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/ucred.h#L91
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_u_cr_label = 0x78;  //__Z15getEntitlementsP5ucred getEntitlements
    off_u_cr_posix = 0x18;  //_kauth_cred_getuid, 0x18
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/ucred.h#L100
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_cr_uid = 0; //kauth_cred_getuid, 0x18 - 0x18
    off_cr_ruid = 0x4;
    off_cr_svuid = 0x8;
    off_cr_ngroups = 0xc;
    off_cr_groups = 0x10;
    off_cr_rgid = 0x50; //kauth_cred_getrgid, 0x68-0x18
    off_cr_svgid = 0x54;
    off_cr_gmuid = 0x58;
    off_cr_flags = 0x5c;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/filedesc.h#L138
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_fd_ofiles = 0;
    off_fd_cdir = 0x20;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/file_internal.h#L125
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_fp_glob = 0x10;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/file_internal.h#L179
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_fg_data = 0x38;
    off_fg_flag = 0x10;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/miscfs/specfs/specdev.h#L77
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_specinfo_si_flags = 0x10;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/vnode_internal.h#L158
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8796.101.5/bsd/sys/vnode_internal.h#L159
    //xnu-8792.41.9 vs xnu-8792.61.2 same
    //xnu-8792.61.2 vs xnu-8792.81.2 same
    //xnu-8792.81.2(~iOS 16.3.x) vs xnu-8796.101.5(iOS 16.4~) different
    //xnu-8796.101.5 vs xnu-8796.121.2 same
    //xnu-8796.121.2 vs xnu-8796.141.3 same
    
    //changed priority with below fields;
    //uint32_t v_holdcount;
    //v_name ~ end should be changed offsets, but same offsets when checked 16.2 vs 16.6.1 (_mac_vnode_label_get same)
    off_vnode_v_ncchildren_tqh_first = 0x30;
    off_vnode_v_ncchildren_tqh_last = 0x38;
    off_vnode_v_nclinks_lh_first = 0x40;
    off_vnode_v_iocount = 0x64; //_vnode_iocount
    off_vnode_v_usecount = 0x60;    //_vnode_usecount
    off_vnode_v_flag = 0x54;    //_vnode_isvroot
    off_vnode_v_kusecount = 0x5c;
    off_vnode_v_references = 0x5b;
    off_vnode_v_lflag = 0x58;
    off_vnode_v_owner = 0x68;
    off_vnode_v_cred = 0x98;
    off_vnode_v_writecount = 0xb0;  //_vnode_writecount
    off_vnode_v_type = 0x70;
    off_vnode_v_id = 0x74;
    off_vnode_vu_ubcinfo = 0x78;
    off_vnode_v_name = 0xb8;    //_vnode_getname
    off_vnode_v_mount = 0xd8;
    off_vnode_v_data = 0xe0;
    off_vnode_v_parent = 0xc0;  //_vnode_parent
    off_vnode_v_label = 0xe8;   //_mac_vnode_label_get ADD
    
    //https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/mount_internal.h#L108
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_mount_mnt_data = 0x11F;
    off_mount_mnt_fsowner = 0x9c0;
    off_mount_mnt_fsgroup = 0x9c4;
    off_mount_mnt_devvp = 0x980;    //_vfs_devvp
    off_mount_mnt_flag = 0x70;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/osfmk/ipc/ipc_space.h#L123
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_ipc_space_is_table = 0x20;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/ubc_internal.h#L156
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3, only cs_blobs has been applied pac)
    off_ubc_info_cs_blobs = 0x50;   //_ubc_cs_blob_get - 14pro 16.1.2 FFFFFFF0081FF240
    off_ubc_info_cs_add_gen = 0x2c;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/osfmk/vm/pmap_cs.h#L299
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_pmap_cs_code_directory_ce_ctx = 0x1c8;
    off_pmap_cs_code_directory_der_entitlements_size = 0x1d8;
    off_pmap_cs_code_directory_trust = 0x1dc;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/osfmk/ipc/ipc_entry.h#L111
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_ipc_entry_ie_object = 0;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/osfmk/ipc/ipc_object.h#L120
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_ipc_object_io_bits = 0;
    off_ipc_object_io_references = 0x4;
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/osfmk/ipc/ipc_port.h#L167
    //should be same 16.0-16.6 (proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_ipc_port_ip_kobject = 0x48; //https://github.com/0x7ff/dimentio/blob/7ffffffb4ebfcdbc46ab5e8f1becc0599a05711d/libdimentio.c#L973
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/ubc_internal.h#L103
    //should be same 16.0-16.6, except off_cs_blob_csb_pmap_cs_entry(proof: xnu src; xnu-8792.41.9 vs xnu-8796.141.3)
    off_cs_blob_csb_cdhash = 0x58;
    off_cs_blob_csb_flags = 0x20;   //_csblob_get_flags
    off_cs_blob_csb_teamid = 0x88;
    //https://gist.github.com/LinusHenze/4cd5d7ef057a144cda7234e2c247c056#file-ios_16_launch_constraints-txt-L39
    off_cs_blob_csb_validation_category = 0xb0; //_csblob_get_validation_category
    
    //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/namei.h#L243
    off_namecache_nc_child_tqe_prev = 0x10; //should be same 16.0-16.6
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"16.3.1")) {
        printf("[i] offsets selected for iOS 16.0 - 16.3.1\n");
        //iPhone 14 Pro 16.0.2, 16.1.2 offsets
        
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/proc_internal.h#L273
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/queue.h#L487
        //xnu-8792.41.9 vs xnu-8792.61.2 same
        //xnu-8792.61.2 vs xnu-8792.81.2 same
        //xnu-8792.81.2(~iOS 16.3.x) vs xnu-8796.101.5(iOS 16.4~) different!
        //xnu-8796.101.5 vs xnu-8796.121.2 same
        //xnu-8796.121.2 vs xnu-8796.141.3 same
        off_p_list_le_prev = 0x8;
        off_p_proc_ro = 0x18;   //_proc_ucred
        off_p_ppid = 0x20;
        off_p_original_ppid = 0x24;
        off_p_pgrpid = 0x28;
        off_p_uid = 0x2c;
        off_p_gid = 0x30;
        off_p_ruid = 0x34;
        off_p_rgid = 0x38;
        off_p_svuid = 0x3c;
        off_p_svgid = 0x40;
        off_p_sessionid = 0x44;
        off_p_puniqueid = 0x48;
        off_p_pid = 0x60;
        off_p_pfd = 0xf8;
        off_p_textvp = 0x350;
        off_p_name = 0x381; //_proc_best_name
        
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/namei.h#L243
        off_namecache_nc_dvp = 0x40; //needed to be change 16.4~
        off_namecache_nc_vp = 0x48; //needed to be change 16.4~
        off_namecache_nc_hashval = 0x50;    //needed to be change 16.4~
        off_namecache_nc_name = 0x58;   //needed to be change 16.4~
        
        
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/ubc_internal.h#L103
        off_cs_blob_csb_pmap_cs_entry = 0xb8;   //no more existing since xnu-8796.101.5+(iOS 16.4+); changed to csb_csm_obj
        
//        off_gphysbase = 0xFFFFFFF0077FF710;
//        off_gphysize = 0xFFFFFFF0077FFAD8;
//        off_gvirtbase = 0xFFFFFFF0077FF708;
//        off_ptov__table = 0xFFFFFFF0077FFA18;
    }
        
    //Starting with iOS 16.4~
    else {
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8796.101.5/bsd/sys/proc_internal.h#L259
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8796.101.5/bsd/sys/queue.h#L487
        //changed with below fields; (~16.3 vs 16.4~+)
        //struct proc_smr p_hash; -> struct smrq_slink p_hash;
        off_p_list_le_prev = 0x8;
        off_p_proc_ro = 0x18;   //_proc_ucred
        off_p_ppid = 0x20;
        off_p_original_ppid = 0x24;
        off_p_pgrpid = 0x28;
        off_p_uid = 0x2c;
        off_p_gid = 0x30;
        off_p_ruid = 0x34;
        off_p_rgid = 0x38;
        off_p_svuid = 0x3c;
        off_p_svgid = 0x40;
        off_p_sessionid = 0x44;
        off_p_puniqueid = 0x48;
        off_p_pid = 0x60;
        off_p_pfd = 0xf8;   //_fp_get_pipe_id
        //changed start
        off_p_textvp = 0x548;//0x350;   //_csproc_get_blob
        off_p_name = 0x579;//0x381; //_proc_best_name
        
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8792.41.9/bsd/sys/namei.h#L243
        //added two fields (so calulate + 8)
        //uint32_t nc_vid;
        //uint32_t nc_counter;
        off_namecache_nc_dvp = 0x48; //needed to be change 16.4~
        off_namecache_nc_vp = 0x50; //needed to be change 16.4~
        off_namecache_nc_hashval = 0x58;    //needed to be change 16.4~
        off_namecache_nc_name = 0x60;   //needed to be change 16.4~
        
        //https://github.com/apple-oss-distributions/xnu/blob/xnu-8796.101.5/bsd/sys/ubc_internal.h#L103
        off_cs_blob_csb_pmap_cs_entry = 0xffff;   //no more existing;; since xnu-8796.101.5+(iOS 16.4+); changed to csb_csm_obj
    }
}
