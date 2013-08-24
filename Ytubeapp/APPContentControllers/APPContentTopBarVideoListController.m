//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopBarVideoListController.h"

@interface APPContentTopBarVideoListController ()
@property bool subtopbarWasVisible;
@end

@implementation APPContentTopBarVideoListController

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"APPContentTopBarVideoListController");
        self.subtopbarWasVisible = TRUE;

        /*__weak id weakSelf = self;
        [[self configureDefaultState] onViewState:tDidInitViewState do:^{
            NSLog(@"APPContentTopBarVideoListController: onViewState:tDidInitViewState");
            // sets sub topbar to visible initially
            //[weakSelf setSubtopbarWasVisible:TRUE]; //= TRUE;
        }];
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^{
            NSLog(@"APPContentTopBarVideoListController: onViewState:tDidAppearViewState");
            // shows sub topbar if was visible
            //if (self.subtopbarWasVisible)
            //    [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }];   */
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    NSLog(@"APPContentTopBarVideoListController: loadView");
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.subtopbarWasVisible)
        [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
}

-(void)resetController
{
    self.subtopbarWasVisible = TRUE;
    [self viewDidAppear:TRUE];
}

-(BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView*)view
{
    if (!self.isDefaultMode) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        if (oldContentOffset.y < newContentOffset.y && [self.tableViewHeaderFormView isHeaderShown] && newContentOffset.y > downAtTopDistance) {
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:YES];
        } else if (oldContentOffset.y > newContentOffset.y && ![self.tableViewHeaderFormView isHeaderShown] && (downAtTopOnly ? (newContentOffset.y < downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - downAtTopDistance)))) {
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }

        //if((newVal.y >= 0.0) && (newVal.y <= self.tableView.contentSize.height)) {
        //}

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)willHide:(void (^)(void))callback
{
    NSLog(@"willHide");
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
}

-(void)didShow:(void (^)(void))callback
{
    NSLog(@"didShow");
    if (self.subtopbarWasVisible) {
        [self.tableViewHeaderFormView showOnCompletion:^(BOOL isShown) {
            if (callback)
                callback();
        }  animated:YES];

    } else {
        if (callback)
            callback();
    }
}

@end