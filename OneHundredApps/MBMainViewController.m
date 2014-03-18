//
//  MBMainViewController.m
//  OneHundredApps
//
//  Created by Michal Banasiak on 18.03.2014.
//  Copyright (c) 2014 SO MANY APPS. All rights reserved.
//

#import "MBMainViewController.h"
#import "MBApplicationsProvider.h"
#import "MBApplicationCell.h"

@interface MBMainViewController ()
{
    MBApplicationsProvider* applicationsProvider;
    
    IBOutlet UIBarButtonItem *refreshButton;
    UIBarButtonItem* refreshIndicator;
}
@end

@implementation MBMainViewController

- (void)dealloc
{
    [applicationsProvider release];
    
    [refreshButton release];
    [refreshIndicator release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [self createRefreshIndicator];
    [self createApplicationsProvider];
    
    [self fetchApplications];
}

- (void)createRefreshIndicator
{
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshIndicator = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    [indicatorView startAnimating];
}

- (void)createApplicationsProvider
{
    NSURLSession* session = [NSURLSession sharedSession];
    applicationsProvider = [[MBApplicationsProvider alloc] initWithURLSession:session];
}

- (IBAction)refresh:(id)sender
{
    [self fetchApplications];
}

- (void)fetchApplications
{
    self.navigationItem.rightBarButtonItem = refreshIndicator;
    
    [applicationsProvider fetchApplicationsWithSuccessBlock:^{
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem = refreshButton;
    } fail:^{
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [applicationsProvider numberOfFetchedApplications];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBApplicationCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MBApplicationCell"];
    NSInteger index = indexPath.row;
    
    cell.ranking.text = [NSString stringWithFormat:@"%ld", (long)index+1];
    cell.name.text = [applicationsProvider nameOfApplicationAtIndex:index];
    
    [applicationsProvider fetchImageForApplicationAtIndex:index completionBlock:^(UIImage *image) {
        cell.image.image = image;
    }];
    
    return cell;
}

@end
