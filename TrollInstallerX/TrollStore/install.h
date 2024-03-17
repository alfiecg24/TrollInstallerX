//
//  install.h
//  TrollInstallerX
//
//  Created by Alfie on 09/03/2024.
//

#ifndef install_h
#define install_h

bool remount_private_preboot(void);
bool install_trollstore(NSString *tar);
bool uicache(void);

#endif /* install_h */
