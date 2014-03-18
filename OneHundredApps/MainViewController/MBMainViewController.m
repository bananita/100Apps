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
    
    [self unregisterDynamicFontNotification];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [self createRefreshIndicator];
    [self createApplicationsProvider];
    [self registerForDynamicFontNotification];
    
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

- (void)registerForDynamicFontNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)unregisterDynamicFontNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (IBAction)refresh:(id)sender
{
    [self fetchApplications];
}

- (void)fetchApplications
{
    [self setRefreshIndicatorVisible:YES];
    
    [applicationsProvider fetchApplicationsWithSuccessBlock:^{
        [self.tableView reloadData];
        
        [self setRefreshIndicatorVisible:NO];
    } failBlock:^{
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Downloading error alert title")
                                                        message:NSLocalizedString(@"Error during downloading apps. Please try again later.", @"Downloading error alert message")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil] autorelease];
        
        [alert show];
        
        [self setRefreshIndicatorVisible:NO];
    } noConnectionBlock:^{
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No internet connection", @"No internet connection alert title")
                                                         message:NSLocalizedString(@"Internet connection is unavailable." , @"No internet connection alert message")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles: nil] autorelease];
        [alert show];
        
        [self setRefreshIndicatorVisible:NO];
    }];
}

- (void)setRefreshIndicatorVisible:(BOOL)visible
{
    id barButtonItem = visible? refreshIndicator : refreshButton;
    self.navigationItem.rightBarButtonItem = barButtonItem;
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
    cell.image.image = nil;
    
    [applicationsProvider fetchImageForApplicationAtIndex:index
                                                taskOwner:cell
                                          completionBlock:^(UIImage *image) {
                                              cell.image.image = image;
                                          }];
    
    cell.name.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    cell.ranking.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    return cell;
}

- (void)didChangePreferredContentSize:(NSNotification*)notification
{
    [self.tableView reloadData];
}

@end
