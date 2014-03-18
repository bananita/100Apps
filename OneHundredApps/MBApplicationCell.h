//
//  MBApplicationCell.h
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBApplicationCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel* ranking;
@property (retain, nonatomic) IBOutlet UIImageView* image;
@property (retain, nonatomic) IBOutlet UILabel* name;

@end
