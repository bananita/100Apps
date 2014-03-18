//
//  MBApplication.m
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import "MBApplication.h"

@implementation MBApplication

- (id)initWithName:(NSString*)aName
          imageURL:(NSString*)anImageURL
{
    self = [super init];
    
    if (!self)
        return nil;
    
    _name = [aName copy];
    _imageURL = [anImageURL copy];
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_imageURL release];
    
    [super dealloc];
}

@end
