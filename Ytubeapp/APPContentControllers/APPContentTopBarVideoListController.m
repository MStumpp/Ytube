//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopBarVideoListController.h"

@interface APPContentTopBarVideoListController ()
@property BOOL subtopbarWasVisible;
@end

@implementation APPContentTopBarVideoListController

-(id)init
{
    self = [super init];
    if (self) {
        self.subtopbarWasVisible = TRUE;

        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            NSLog(@"testest 5a");
            // save state of header form
            if ([self.tableViewHeaderFormView isHeaderShown]) {
                [self setSubtopbarWasVisible:TRUE];
            } else {
                [self setSubtopbarWasVisible:FALSE];
            }
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
            NSLog(@"testest 5b");
        }];

        [[self configureState:tActiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // show header form if was visible
            NSLog(@"testest 3a");
            NSLog(@"%@", [NSThread currentThread]);
            if (self.subtopbarWasVisible) {
                NSLog(@"%@", [NSThread currentThread]);
                [self.tableViewHeaderFormView showOnCompletion:nil animated:NO];
            }
            NSLog(@"testest 3b");
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

-(BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView*)view
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
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

@end