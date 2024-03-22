//
//  libfragmentzip.h
//  libfragmentzip
//
//  Created by tihmstar on 24.12.16.
//  Copyright © 2016 tihmstar. All rights reserved.
//

#ifndef libfragmentzip_h
#define libfragmentzip_h

#include <curl/curl.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>

#ifdef _WIN32
#define STATIC_INLINE static __inline
#define ATTRIBUTE_PACKED
#pragma pack(push)
#pragma pack(1)
#else
#define STATIC_INLINE static inline
#define ATTRIBUTE_PACKED __attribute__ ((packed))
#endif

#define makeBE64(a) makeEndian((char *)(&(a)), 8, 1)
#define makeLE64(a) makeEndian((char *)(&(a)), 8, 0)
#define makeBE32(a) makeEndian((char *)(&(a)), 4, 1)
#define makeLE32(a) makeEndian((char *)(&(a)), 4, 0)
#define makeBE16(a) makeEndian((char *)(&(a)), 2, 1)
#define makeLE16(a) makeEndian((char *)(&(a)), 2, 0)

#define fragmentzip_nextCD(cd) ((fragmentzip_cd *)(cd->filename+cd->len_filename+cd->len_extra_field+cd->len_file_comment))

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>

typedef struct{
    uint32_t signature;
    uint16_t version;
    uint16_t flags;
    uint16_t compression;
    uint16_t modtime;
    uint16_t moddate;
    uint32_t crc32;
    uint32_t size_compressed;
    uint32_t size_uncompressed;
    uint16_t len_filename;
    uint16_t len_extra_field;
    char filename[0]; //variable length
//    char extra_field[]; //variable length
} ATTRIBUTE_PACKED fragentzip_local_file;

typedef struct{
    uint32_t signature;
    uint16_t disk_cur_number;
    uint16_t disk_cd_start_number;
    uint16_t cd_disk_number;
    uint16_t cd_entries;
    uint32_t cd_size;
    uint32_t cd_start_offset;
    uint16_t comment_len;
} ATTRIBUTE_PACKED fragmentzip_end_of_cd;

typedef struct{
    uint32_t signature;
    uint64_t end_of_cd_size;
    uint16_t version_made;
    uint16_t version_needed;
    uint32_t disk_cur_number;
    uint32_t disk_cd_start_number;
    uint64_t cd_disk_number;
    uint64_t cd_entries;
    uint64_t cd_size;
    uint64_t cd_start_offset;
} ATTRIBUTE_PACKED fragmentzip64_end_of_cd;
    
typedef struct{
    uint32_t signature;
    uint32_t disk_cd_start_number;
    uint64_t end_of_cd_record_offset;
    uint32_t cd_disk_number;
} ATTRIBUTE_PACKED fragmentzip64_end_of_cd_locator;
    
typedef struct{
    uint32_t signature;
    uint16_t version;
    uint16_t pkzip_version_needed;
    uint16_t flags;
    uint16_t compression;
    uint16_t modtime;
    uint16_t moddate;
    uint32_t crc32;
    uint32_t size_compressed;
    uint32_t size_uncompressed;
    uint16_t len_filename;
    uint16_t len_extra_field;
    uint16_t len_file_comment;
    uint16_t disk_num;
    uint16_t internal_attribute;
    uint32_t external_attribute;
    uint32_t local_header_offset;
    char filename[0]; //variable length
//    char extra_field[0]; //variable length
//    char file_comment[0]; //variable length
} ATTRIBUTE_PACKED fragmentzip_cd;

typedef struct{
    uint16_t field_tag; //needs to be 0x0001
    uint16_t field_size;
    uint64_t extrafield[0];
//    uint64_t size_uncompressed;
//    uint64_t size_compressed;
//    uint64_t local_header_offset;
//    uint32_t disk_num;
} ATTRIBUTE_PACKED fragmentzip64_extended_information_extra_field;
    

typedef struct fragmentzip_info{
    char *url;
    CURL *mcurl;
    FILE *localFile;
    uint64_t length;
    int isZIP64;
    fragmentzip_cd *cd;
    uint64_t cd_entries;
    struct {
        struct{
            fragmentzip_end_of_cd *cd_end;
        };
        struct{
            fragmentzip64_end_of_cd *cd64_end;
            fragmentzip64_end_of_cd_locator *cd64_end_locator;
        };
    } internal;
} fragmentzip_t;


STATIC_INLINE bool isBigEndian(void) {
    static const uint32_t tst = 0x41424344;
    return (bool)__builtin_expect(((char*)&tst)[0] == 0x41,0);
}

STATIC_INLINE void makeEndian(char * buf, unsigned int size, bool big) {
    if (isBigEndian() != big){
        switch (size) {
            case 2:
                buf[0] ^= buf[1];
                buf[1] ^= buf[0];
                buf[0] ^= buf[1];
                break;
            case 4:
                buf[0] ^= buf[3];
                buf[3] ^= buf[0];
                buf[0] ^= buf[3];
                
                buf[2] ^= buf[1];
                buf[1] ^= buf[2];
                buf[2] ^= buf[1];
                break;
                
            default:
                printf("[FATAL] operation not supported\n");
                exit(1);
                break;
        }
    }
}

typedef void (*fragmentzip_process_callback_t)(unsigned int progress);

fragmentzip_t *fragmentzip_open(const char *url);
fragmentzip_t *fragmentzip_open_extended(const char *url, CURL *mcurl); //pass custom CURL with web auth by basic/digest or cookies

//outbuf will be allocated by libfragmentzip, caller is responsible for freeing
int fragmentzip_download_to_memory(fragmentzip_t *info, const char *remotepath, char **outBuf, size_t *outSize, fragmentzip_process_callback_t callback);

int fragmentzip_download_file(fragmentzip_t *info, const char *remotepath, const char *savepath, fragmentzip_process_callback_t callback);
void fragmentzip_close(fragmentzip_t *info);

fragmentzip_cd *fragmentzip_getCDForPath(fragmentzip_t *info, const char *path);
fragmentzip_cd *fragmentzip_getNextCD(fragmentzip_cd *cd);

int fragmentzip_getFileInfo(fragmentzip_cd *cd, uint64_t *compressedSize, uint64_t *uncompressedSize, uint64_t *headerOffset, uint32_t *disk_num);

const char* fragmentzip_version(void);

#ifdef __cplusplus
}
#endif

#endif /* libfragmentzip_h */
