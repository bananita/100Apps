//
//  MBApplication.h
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBApplication : NSObject

- (id)initWithName:(NSString*)aName
          imageURL:(NSString*)anImageURL;

@property(nonatomic, copy, readonly) NSString* name;
@property(nonatomic, copy, readonly) NSString* imageURL;

@end
