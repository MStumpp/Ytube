//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopEditBarController.h"

@implementation APPContentTopEditBarController

-(id)init
{
    self = [super init];
    if (self) {
        [[self configureDefaultState] onViewState:tWillAppearViewState do:^{
            [self.editButton setSelected:NO];
            [self.tableView setEditing:NO animated:YES];
        }];
        [self toDefaultStateForce];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.frame = CGRectMake(0.0, 0.0, 49.0, 44.0);
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_up"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateSelected];
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateHighlighted];
    [self.backButton setTag:tBack];
    [subtopbarContainer addSubview:self.backButton];

    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(271.0, 0.0, 49.0, 44.0)];
    [self.editButton addTarget:self action:@selector(editButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_up"] forState:UIControlStateNormal];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_down"] forState:UIControlStateHighlighted];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_down"] forState:UIControlStateSelected];
    [self.editButton setTag:tEdit];
    [subtopbarContainer addSubview:self.editButton];

    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer];
}

// TODO: Brauchen wir das hier?
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController.viewControllers count] > 1)
        self.backButton.hidden = NO;
    else
        self.backButton.hidden = YES;
}

-(void)back
{
    if ([self.navigationController.viewControllers count] > 1)
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)editButtonPress:(id)sender
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

@end