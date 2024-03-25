//
//  escalate.h
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

#ifndef escalate_h
#define escalate_h

#include <stdio.h>

void post_kernel_exploit(bool iOS14);
bool build_physrw_primitive(void);

bool get_root_krw(bool iOS14);
bool drop_root_krw(bool iOS14);
bool get_root_pplrw(void);
bool unsandbox(void);
bool platformise(void);

#endif /* escalate_h */
