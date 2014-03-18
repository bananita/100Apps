//
//  MBApplicationCell.m
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import "MBApplicationCell.h"

@implementation MBApplicationCell
@synthesize task = _task;


- (void)dealloc {
    [_ranking release];
    [_image release];
    [_name release];
    [_task release];

    [super dealloc];
}

@end
