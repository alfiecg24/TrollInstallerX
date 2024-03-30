//
//  update.h
//  TrollInstallerX
//
//  Created by Alfie on 30/03/2024.
//

#ifndef update_h
#define update_h

#import <Foundation/Foundation.h>
void github_fetchLatestVersion(NSString* repo, void (^completionHandler)(NSString* latestVersion));

#endif /* update_h */
