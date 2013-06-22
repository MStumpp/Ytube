//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopBarVideoListController.h"

@interface APPContentTopBarVideoListController ()
// TODO: shown initially wirklich notwendig
@property BOOL subtopbarShownInitially;
@property BOOL subtopbarWasVisible;
@end

@implementation APPContentTopBarVideoListController

-(id)init
{
    self = [super init];
    if (self) {
        self.downAtTopOnly = TRUE;
        self.downAtTopDistance = 40;

        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^{
            self.subtopbarShownInitially = FALSE;
            self.subtopbarWasVisible = FALSE;
        }] onViewState:tDidAppear do:^{
            [self onViewState:tDidAppear when:!self.subtopbarShownInitially doOnce:^{
                [self.tableViewHeaderFormView showOnCompletion:^(BOOL isShown){
                    if (isShown)
                        self.subtopbarShownInitially = TRUE;
                } animated:YES];
            }];
        }];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    self.tableViewHeaderFormView = nil;
}

-(BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView *)view
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

-(void)willHide:(void (^)(void))callback
{
    if (!self.isDefaultMode) {
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

-(void)didShow:(void (^)(void))callback
{
    if (self.isDefaultMode) {
        [self onViewState:tDidAppear when:!self.subtopbarShownInitially doOnce:^{
            [self.tableViewHeaderFormView showOnCompletion:^(BOOL isShown){
                if (isShown)
                    self.subtopbarShownInitially = TRUE;
            } animated:YES];
        }];

        [self onViewState:tDidAppear when:self.subtopbarWasVisible doOnce:^{
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }];
    } else {
        if (callback)
            callback();
    }
}

@end