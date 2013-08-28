//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopToggleBarVideoListController.h"

@interface APPContentTopToggleBarVideoListController ()
@property BOOL subtopbarWasVisible1;
@property BOOL subtopbarWasVisible2;
@end

@implementation APPContentTopToggleBarVideoListController

-(id)init
{
    self = [super init];
    if (self) {
        self.subtopbarWasVisible1 = TRUE;
        self.subtopbarWasVisible2 = FALSE;

        [[self configureDefaultState] onViewState:tDidAppearViewState do:^{
            [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
                if (isHidden)
                    [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
            } animated:YES];
            [self.tableView scrollsToTop];
        }];
    }
    return self;
}

-(void)loadView
{
    [super loadView];

    self.tableViewHeaderFormView2 = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];

    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0.0, 0.0, 49.0, 44.0);
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_up"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateSelected];
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.backButton];

    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(227.0, 0.0, 49.0, 44.0);
    [self.editButton addTarget:self action:@selector(editButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_up"] forState:UIControlStateNormal];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_down"] forState:UIControlStateHighlighted];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_down"] forState:UIControlStateSelected];
    [self.editButton setTag:tEdit];
    [subtopbarContainer addSubview:self.editButton];

    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(276.0, 0.0, 44.0, 44.0);
    [addButton addTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"sub_top_bar_plus_up"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"sub_top_bar_plus_down"] forState:UIControlStateHighlighted];
    [addButton setImage:[UIImage imageNamed:@"sub_top_bar_plus_down"] forState:UIControlStateSelected];
    [addButton setTag:tAdd];
    [subtopbarContainer addSubview:addButton];

    self.tableViewHeaderFormView1 = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableViewHeaderFormView2 headerView:subtopbarContainer delegate:self];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    self.tableViewHeaderFormView1 = nil;
    self.tableViewHeaderFormView2 = nil;
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

-(void)addButtonPress:(id)sender
{
    if ([self.tableViewHeaderFormView1 isHeaderShown]) {
        [self.tableViewHeaderFormView1 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden)
                [self.tableViewHeaderFormView2 showOnCompletion:nil animated:YES];
        } animated:YES];
    }
}

-(void)willHide:(void (^)(void))callback
{
    if ([self.tableViewHeaderFormView1 isHeaderShown]) {
        self.subtopbarWasVisible1 = TRUE;
        [self.tableViewHeaderFormView1 hideOnCompletion:^(BOOL isHidden) {
            if (callback)
                callback();
        } animated:YES];

    } else if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        self.subtopbarWasVisible2 = TRUE;
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (callback)
                callback();
        } animated:YES];

    } else {
        self.subtopbarWasVisible1 = FALSE;
        self.subtopbarWasVisible2 = FALSE;
        if (callback)
            callback();
    }
}

-(void)didShow:(void (^)(void))callback
{
    if (self.subtopbarWasVisible1) {
        [self.tableViewHeaderFormView1 showOnCompletion:^(BOOL isShown) {
            if (callback)
                callback();
        }  animated:YES];

    } else if (self.subtopbarWasVisible2) {
        [self.tableViewHeaderFormView2 showOnCompletion:^(BOOL isShown) {
            if (callback)
                callback();
        }  animated:YES];

    } else {
        if (callback)
            callback();
    }
}

@end