//
//  appledb.m
//  TrollInstallerX
//
//  Created by Dhinak G on 3/4/24.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#if !TARGET_OS_OSX
#import <UIKit/UIKit.h>
#endif
#import <sys/sysctl.h>

#define BASE_URL @"https://api.appledb.dev/ios/"

NSArray *hostsNeedingAuth = @[@"adcdownload.apple.com", @"download.developer.apple.com", @"developer.apple.com"];

static NSString *getAPIURL(void) {
    NSString *osStr = nil;
#if TARGET_OS_MACCATALYST || TARGET_OS_OSX
    osStr = @"macOS";
#else
    if (NSProcessInfo.processInfo.iOSAppOnMac) {
        osStr = @"macOS";
    } else {
        switch (UIDevice.currentDevice.userInterfaceIdiom) {
            case UIUserInterfaceIdiomPad:
                if (@available(iOS 13.0, *)) {
                    osStr = @"iPadOS";
                }
            case UIUserInterfaceIdiomPhone:
                osStr = @"iOS";
                break;
            case UIUserInterfaceIdiomTV:
                osStr = @"tvOS";
                break;
            case UIUserInterfaceIdiomMac:
                osStr = @"macOS";
                break;
            default:
                break;
        }
    }
#endif

    if (!osStr) {
        return nil;
    }

    char build[256];
    size_t size = sizeof(build);
    int result = sysctlbyname("kern.osversion", &build, &size, NULL, 0);
    if (result) {
        return nil;
    }

    return [NSString stringWithFormat:@"https://api.appledb.dev/ios/%@;%s.json", osStr, build];
}

static NSString *getModelIdentifier(void) {
    char modelIdentifier[256];
    size_t size = sizeof(modelIdentifier);
    int result = sysctlbyname("hw.model", &modelIdentifier, &size, NULL, 0);
    if (result) {
        return nil;
    }

    return [NSString stringWithCString:modelIdentifier encoding:NSUTF8StringEncoding];
}

static NSData *makeSynchronousRequest(NSString *url, __strong NSError **error) {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *data = nil;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:url]
                                        completionHandler:^(NSData *_data, NSURLResponse *response, NSError *_error) {
                                            data = _data;
                                            if (error) {
                                                *error = _error;
                                            }
                                            dispatch_semaphore_signal(semaphore);
                                        }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return data;
}

NSString *getFirmwareURL(bool *isOTA) {
    NSString *apiURL = getAPIURL();
    if (!apiURL) {
        return nil;
    }

    NSError *error = nil;
    NSData *data = makeSynchronousRequest(apiURL, &error);
    if (error) {
        return nil;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        return nil;
    }

    NSString *modelIdentifier = getModelIdentifier();

    for (NSDictionary<NSString *, id> *source in json[@"sources"]) {
        if (![@[@"ota", @"ipsw"] containsObject:source[@"type"]]) {
            continue;
        }

        if ([source[@"type"] isEqualToString:@"ota"] && source[@"prerequisiteBuild"]) {
            // ignore deltas
            continue;
        }

        if (![source[@"deviceMap"] containsObject:modelIdentifier]) {
            continue;
        }

        for (NSDictionary<NSString *, id> *link in source[@"links"]) {
            NSURL *url = [NSURL URLWithString:link[@"url"]];
            if ([hostsNeedingAuth containsObject:url.host]) {
                continue;
            }

            if (!link[@"active"]) {
                continue;
            }

            if (isOTA) {
                *isOTA = [source[@"type"] isEqualToString:@"ota"];
            }
            return link[@"url"];
        }
    }

    return nil;
}
