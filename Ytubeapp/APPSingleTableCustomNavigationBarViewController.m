//
//  APPSingleTableCustomNavigationBarViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableCustomNavigationBarViewController.h"

@interface APPSingleTableCustomNavigationBarViewController ()
@property BOOL form1WasVisible;
@property BOOL form2WasVisible;
@end

@implementation APPSingleTableCustomNavigationBarViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.form1WasVisible = FALSE;
            self.form2WasVisible = FALSE;
        }] onViewState:tDidAppear do:^{
            [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
                if (isHidden)
                    [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
            } animated:YES];
            [self.tableView scrollsToTop];
        }];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.tableViewHeaderFormView2 = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableViewMaskView headerView:nil delegate:self];
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableViewHeaderFormView1 = nil;
    self.tableViewHeaderFormView2 = nil;
}

- (void)addButtonPress:(id)sender
{
    if ([self.tableViewHeaderFormView1 isHeaderShown]) {
        [self.tableViewHeaderFormView1 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden)
                [self.tableViewHeaderFormView2 showOnCompletion:nil animated:YES];
        } animated:YES];
    }
}

- (void)cancelButtonPress:(id)sender
{
    if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        self.textField.text = @"";
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden) {
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
            }
        } animated:YES];
    }
}

// "APPSliderViewConrollerDelegate" Protocol

- (void)didFullScreenMode:(void (^)(void))callback
{
    if (!self.isInFullscreenMode) {
        self.isInFullscreenMode = TRUE;

        [self onViewState:tDidAppear when:self.form1WasVisible doOnce:^(){
            [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
        }];
        
        [self onViewState:tDidAppear when:self.form2WasVisible doOnce:^(){
            [self.tableViewHeaderFormView2 showOnCompletion:nil animated:YES];
        }];
    }
    
    if (callback)
        callback();
}

- (void)willSplitScreenMode:(void (^)(void))callback
{
    [self modeChange:callback];
}

- (void)willBeToppedMode:(void (^)(void))callback
{
    [self modeChange:callback];
}

- (void)modeChange:(void (^)(void))callback
{
    if (self.isInFullscreenMode) {
        self.isInFullscreenMode = FALSE;
        
        // slide sub header menu up and
        if ([self.tableViewHeaderFormView1 isHeaderShown]) {
            self.form1WasVisible = TRUE;
            [self.tableViewHeaderFormView1 hideOnCompletion:^(BOOL isHidden) {
                if (callback)
                    callback();
            } animated:YES];
            
        } else if ([self.tableViewHeaderFormView2 isHeaderShown]) {
            self.form2WasVisible = TRUE;
            [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
                if (callback)
                    callback();
            } animated:YES];
            
        } else {
            self.form1WasVisible = FALSE;
            self.form2WasVisible = FALSE;
            if (callback)
                callback();
        }
        
    } else {
        if (callback)
            callback();
    }
}

@end
