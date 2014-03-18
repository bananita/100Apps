//
//  MBApplicationsProvider.m
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import "MBApplicationsProvider.h"
#import "MBApplication.h"

static NSString* kMBAppleFeedURL = @"https://itunes.apple.com/us/rss/toppaidapplications/limit=100/json";

@interface MBApplicationsProvider ()
{
    NSURLSession* session;
    NSArray* fetchedApplications;
}

@end

@implementation MBApplicationsProvider

- (id)initWithURLSession:(NSURLSession*)aSession
{
    self = [super init];
    
    if (!self)
        return nil;
    
    session = [aSession retain];
    
    return self;
}

- (void)dealloc
{
    [session release];
    [fetchedApplications release];
    
    [super dealloc];
}

- (void)fetchApplicationsWithSuccessBlock:(void(^)())success
                                failBlock:(void(^)())fail
{
    NSURL *url = [NSURL URLWithString:kMBAppleFeedURL];
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithURL:url
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               [self processResponseWithData:data
                                    response:response
                                       error:error
                                successBlock:success
                                   failBlock:fail];
           }];
    
    [dataTask resume];
}

- (void)processResponseWithData:(NSData*)data
                       response:(NSURLResponse*)response
                          error:(NSError*)error
                   successBlock:(void(^)())success
                      failBlock:(void(^)())fail
{
    
    if (error) {
        fail();
        return;
    }
    
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
    if (httpResp.statusCode != 200) {
        fail();
        return;
    }
    
    NSError *jsonError = nil;
    NSDictionary *applicationsJSON =
    [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingAllowFragments
                                      error:&jsonError];
    
    if (jsonError) {
        fail();
        return;
    }

    NSMutableArray* fetchResults = [NSMutableArray new];
    
    NSArray* applications = applicationsJSON[@"feed"][@"entry"];
    
    for (id obj in applications) {
        NSString* name = obj[@"title"][@"label"];
        NSString* imageURL = obj[@"im:image"][0][@"label"];
        
        MBApplication* application = [[MBApplication alloc] initWithName:name
                                                                imageURL:imageURL];
        
        [fetchResults addObject:application];
        
        [application release];
    }

    dispatch_sync(dispatch_get_main_queue(), ^{
        [fetchedApplications release];
        fetchedApplications = fetchResults;

        success();
    });
}

- (NSInteger)numberOfFetchedApplications
{
    return fetchedApplications.count;
}

- (NSString*)nameOfApplicationAtIndex:(NSInteger)index
{
    MBApplication* application = fetchedApplications[index];
    
    return application.name;
}

- (void)fetchImageForApplicationAtIndex:(NSInteger)index
                              taskOwner:(id<MBTaskOwner>)taskOwner
                        completionBlock:(void(^)(UIImage* image))completionBlock
{
    MBApplication* application = fetchedApplications[index];
    [taskOwner.task cancel];

    NSURLSessionTask* task = [session dataTaskWithURL:[NSURL URLWithString:application.imageURL]
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error) {
        UIImage *downloadedImage = [UIImage imageWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(downloadedImage);
        });
    }];
    
    [task resume];
    
    taskOwner.task = task;
}

@end
