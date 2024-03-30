//
//  update.m
//  TrollInstallerX
//
//  Created by Alfie on 30/03/2024.
//

#import <Foundation/Foundation.h>

void github_fetchLatestVersion(NSString* repo, void (^completionHandler)(NSString* latestVersion))
{
    NSString* urlString = [NSString stringWithFormat:@"https://api.github.com/repos/%@/releases/latest", repo];
    NSURL* githubLatestAPIURL = [NSURL URLWithString:urlString];

    NSURLSessionDataTask* task = [NSURLSession.sharedSession dataTaskWithURL:githubLatestAPIURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(!error)
        {
            if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

                if (!jsonError)
                {
                    completionHandler(jsonResponse[@"tag_name"]);
                }
            }
        }
    }];

    [task resume];
}
