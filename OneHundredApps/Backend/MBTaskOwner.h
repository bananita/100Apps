//
//  MBTaskOwner.h
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBTaskOwner <NSObject>

@property(nonatomic, retain) NSURLSessionTask* task;

@end
