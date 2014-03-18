//
//  MBApplicationsProvider.h
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBApplicationsProvider : NSObject

- (id)initWithURLSession:(NSURLSession*)aSession;

- (void)fetchApplicationsWithSuccessBlock:(void(^)())success
                                     fail:(void(^)())fail;

- (NSInteger)numberOfFetchedApplications;
- (NSString*)nameOfApplicationAtIndex:(NSInteger)index;

- (void)fetchImageForApplicationAtIndex:(NSInteger)index
                        completionBlock:(void(^)(UIImage* image))completionBlock;

@end
