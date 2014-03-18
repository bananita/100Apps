//
//  MBApplicationsProvider.m
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import "MBApplicationsProvider.h"
#import "MBApplication.h"
#import "Reachability.h"

static NSString* kMBAppleFeedURL = @"https://itunes.apple.com/us/rss/toppaidapplications/limit=100/json";

@interface MBApplicationsProvider ()
{
    NSURLSession* session;
    NSArray* fetchedApplications;
    Reachability* reachability;
    
    BOOL connectionAvailable;
}

@end

@implementation MBApplicationsProvider

- (id)initWithURLSession:(NSURLSession*)aSession
{
    self = [super init];
    
    if (!self)
        return nil;
    
    session = [aSession retain];
    
    [self startInternetAccessMonitoring];

    
    return self;
}

- (void)dealloc
{
    [session release];
    [fetchedApplications release];
    
    [self stopInternetAccessMonitoring];
    
    [super dealloc];
}

- (void)startInternetAccessMonitoring
{
    reachability = [[Reachability reachabilityForInternetConnection] retain];
    [reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [self refreshConnectionStatus];
}

- (void)stopInternetAccessMonitoring
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
    
    [reachability stopNotifier];
    [reachability release];
    reachability = nil;
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    [self refreshConnectionStatus];
}

- (void)refreshConnectionStatus
{
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    connectionAvailable = (networkStatus != NotReachable);
}

- (void)fetchApplicationsWithSuccessBlock:(void(^)())success
                                failBlock:(void(^)())fail
{
    [self showNoConnectionAlertIfNeeded];
    
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

- (void)showNoConnectionAlertIfNeeded
{
    if (connectionAvailable)
        return;
    
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No internet connection", @"No internet connection alert title")
                                                     message:NSLocalizedString(@"Internet connection is unavailable." , @"No internet connection alert message")
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil] autorelease];
    [alert show];
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
