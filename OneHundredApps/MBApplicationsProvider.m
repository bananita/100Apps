//
//  MBApplicationsProvider.m
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import "MBApplicationsProvider.h"
#import "MBApplication.h"

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
    
    [super dealloc];
}

- (void)fetchApplicationsWithSuccessBlock:(void(^)())success
                                     fail:(void(^)())fail
{
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/toppaidapplications/limit=100/json"];
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithURL:url
           completionHandler:^(NSData *data,
                               NSURLResponse *response,
                               NSError *error) {
               if (!error) {
                   NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                   if (httpResp.statusCode == 200) {
                       
                       NSError *jsonError = nil;
                       
                       NSDictionary *applicationsJSON =
                       [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingAllowFragments
                                                         error:&jsonError];
                       if (!jsonError) {
                           NSMutableArray* fetchResults = [NSMutableArray new];
                           
                           id applications = applicationsJSON[@"feed"][@"entry"];
                           
                           [applications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                               NSString* name = obj[@"title"][@"label"];
                               NSString* imageURL = obj[@"im:image"][0][@"label"];
                               
                               MBApplication* application = [[MBApplication alloc] initWithName:name imageURL:imageURL];
                               
                               [fetchResults addObject:application];
                           }];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               fetchedApplications = [fetchResults copy];
                               success();
                               [fetchResults release];
                           });
                       }
                   }
               }
               
           }];

    [dataTask resume];
}

- (NSInteger)numberOfFetchedApplications
{
    return fetchedApplications.count;
}

- (NSString*)nameOfApplicationAtIndex:(NSInteger)index
{
    MBApplication* application = fetchedApplications[index];
    
    return [application.name autorelease];
}

- (void)fetchImageForApplicationAtIndex:(NSInteger)index
                        completionBlock:(void(^)(UIImage* image))completionBlock
{
    
}

@end
