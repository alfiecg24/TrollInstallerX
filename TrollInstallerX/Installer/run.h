//
//  run.h
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

#ifndef run_h
#define run_h

NSString* get_NSString_from_file(int fd);
int run_binary(NSString* path, NSArray* args, NSString** output);

#endif /* run_h */
