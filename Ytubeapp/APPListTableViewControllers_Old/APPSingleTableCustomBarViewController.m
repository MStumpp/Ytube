//
//  APPSingleTableCustomBarViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableCustomBarViewController.h"

@interface APPSingleTableCustomBarViewController ()
@property BOOL subtopbarShownInitially;
@property BOOL subtopbarWasVisible;
@end

@implementation APPSingleTableCustomBarViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.subtopbarShownInitially = FALSE;
            self.subtopbarWasVisible = FALSE;
        }] onViewState:tDidAppear do:^{
            [self onViewState:tDidAppear when:!self.subtopbarShownInitially doOnce:^(){
                [self.tableViewHeaderFormView showOnCompletion:^(BOOL isShown){
                    if (isShown)
                        self.subtopbarShownInitially = TRUE;                
                } animated:YES];
            }];
        }];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableViewMaskView headerView:nil delegate:self];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableViewHeaderFormView = nil;
}

- (BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView *)view
{
    if (self.isInFullscreenMode) {
        return TRUE;
    } else {
        return FALSE;
    }
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

// "HasTableView" Protocol

- (void)beforeShowModeChange
{
    if (self.showMode && [self.buttons objectForKey:[NSNumber numberWithInt:self.showMode]])
        [[self.buttons objectForKey:[NSNumber numberWithInt:self.showMode]] setSelected:NO];
}

- (void)afterShowModeChange
{
    if (self.showMode && [self.buttons objectForKey:[NSNumber numberWithInt:self.showMode]])
        [[self.buttons objectForKey:[NSNumber numberWithInt:self.showMode]] setSelected:YES];
}

// "APPSliderViewConrollerDelegate" Protocol

- (void)didFullScreenModeInitially:(void (^)(void))callback
{
    [self didShow:callback];
}

- (void)willSplitScreenMode:(void (^)(void))callback
{
    [self willHide:callback];
}

- (void)didFullScreenModeAfterSplitScreen:(void (^)(void))callback
{
    [self didShow:callback];
}

// "TVNavigationControllerDelegate" protocol

- (void)willBePushed:(void (^)(void))callback controller:(UIViewController *)controller context:(id)context
{
    [self willHide:callback];
}

- (void)willBePopped:(void (^)(void))callback controller:(UIViewController *)controller context:(id)context
{
    [self willHide:callback];
}

- (void)didFullScreenAfterPop:(void (^)(void))callback controller:(UIViewController *)controller context:(id)context
{
    [self didShow:callback];
}

- (void)didFullScreenAfterPush:(void (^)(void))callback controller:(UIViewController *)controller context:(id)context
{
    [self didShow:callback];
}

- (void)didShow:(void (^)(void))callback
{
    if (!self.isInFullscreenMode) {
        self.isInFullscreenMode = TRUE;
        
        [self onViewState:tDidAppear when:!self.subtopbarShownInitially doOnce:^(){
            [self.tableViewHeaderFormView showOnCompletion:^(BOOL isShown){
                if (isShown)
                    self.subtopbarShownInitially = TRUE;
            } animated:YES];
        }];
        
        [self onViewState:tDidAppear when:self.subtopbarWasVisible doOnce:^(){
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }];
    }
    
    if (callback)
        callback();
}

- (void)willHide:(void (^)(void))callback
{
    if (self.isInFullscreenMode) {
        self.isInFullscreenMode = FALSE;
        
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
