//
//  APPSingleTableNavigationBarViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableNavigationBarViewController.h"

@interface APPSingleTableNavigationBarViewController ()
@property BOOL subtopbarWasVisible;
@end

@implementation APPSingleTableNavigationBarViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.subtopbarWasVisible = FALSE;
        }] onViewState:tDidAppear do:^{
            [self.tableViewHeaderFormView showOnCompletion:^(BOOL isShown){} animated:YES];
            [self.tableView scrollsToTop];
        }];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableViewMaskView headerView:nil delegate:self];

    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.frame = CGRectMake(0.0, 0.0, 49.0, 44.0);
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_up"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateSelected];
    [self.backButton setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateHighlighted];
    [subtopbarContainer addSubview:self.backButton];
    
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(271.0, 0.0, 49.0, 44.0)];
    [self.editButton addTarget:self action:@selector(editButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_up"] forState:UIControlStateNormal];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_down"] forState:UIControlStateHighlighted];
    [self.editButton setImage:[UIImage imageNamed:@"sub_top_bar_edit_down"] forState:UIControlStateSelected];
    [self.editButton setTag:tEdit];
    [subtopbarContainer addSubview:self.editButton];
    
    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableViewHeaderFormView = nil;
}

- (BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView *)view
{
    if (self.isInFullscreenMode)
        return TRUE;
    else
        return FALSE;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        if (oldContentOffset.y < newContentOffset.y && [self.tableViewHeaderFormView isHeaderShown] && newContentOffset.y > self.downAtTopDistance) {
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:YES];
        } else if (oldContentOffset.y > newContentOffset.y && ![self.tableViewHeaderFormView isHeaderShown] && (self.downAtTopOnly ? (newContentOffset.y < self.downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - self.downAtTopDistance)))) {
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }
        
        //if((newVal.y >= 0.0) && (newVal.y <= self.tableView.contentSize.height)) {
        //}
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// "APPSliderViewConrollerDelegate" Protocol

- (void)didFullScreenMode:(void (^)(void))callback
{
    if (!self.isInFullscreenMode) {
        self.isInFullscreenMode = TRUE;
        
        [self onViewState:tDidAppear when:self.subtopbarWasVisible doOnce:^(){
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
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
        if ([self.tableViewHeaderFormView isHeaderShown]) {
            self.subtopbarWasVisible = TRUE;
            [self.tableViewHeaderFormView hideOnCompletion:^(BOOL isHidden) {
                if (callback)
                    callback();
            } animated:YES];
        } else {
            self.subtopbarWasVisible = FALSE;
            if (callback)
                callback();
        }
        
    } else {
        if (callback)
            callback();
    }
}

@end
