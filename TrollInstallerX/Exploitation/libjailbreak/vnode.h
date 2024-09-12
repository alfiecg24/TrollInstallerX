//
//  vnode.h
//  TrollInstallerX
//
//  Created by Alfie on 01/04/2024.
//

#ifndef VNODE_H
#define VNODE_H

#import <Foundation/Foundation.h>

NSArray *get_installed_apps(void);
bool is_persistence_helper_installed(const char **pathOut);
bool install_persistence_helper_via_vnode(const char *bundlePath);

#endif /* VNODE_H */

