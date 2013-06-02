//
//  APPSingleTableHeaderViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableHeaderViewController.h"

@implementation APPSingleTableHeaderViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.downAtTopOnly = TRUE;
        self.downAtTopDistance = 40;
        
        [[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tWillAppear do:^{
            [self.editButton setSelected:NO];
            [self.tableView setEditing:NO animated:YES];
        }];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Should move to some class containing navigation bar specific code
    if ([self.navigationController.viewControllers count] > 1)
        self.backButton.hidden = NO;
    else
        self.backButton.hidden = YES;
}

- (void)subtopbarButtonPress:(UIButton*)sender
{
    if ([sender tag] != self.showMode) {
        [self toShowMode:[sender tag]];
    }
}

// Should move to some class containing navigation bar specific code

- (void)editButtonPress:(id)sender
{
    if ([sender isSelected]) {
        [self.tableView setEditing:NO animated:YES];
        [self.editButton setSelected:NO];

    } else {
        self.tmpEditingCell = nil;
        if ([self.tableView isEditing]) {
            [self.tableView setEditing:NO animated:NO];
            [self.tableView setEditing:YES animated:NO];
        } else {
            [self.tableView setEditing:YES animated:YES];
        }
        
        [self.editButton setSelected:YES];
    }
}

// Should move to some class containing navigation bar specific code

- (void)back
{
    if ([self.navigationController.viewControllers count] > 1)
        [(TVNavigationController*)self.navigationController popViewControllerOnCompletion:nil context:nil animated:YES];
}

@end
