//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopBarVideoListController.h"

@interface APPContentTopBarVideoListController()
@property BOOL subtopbarWasVisible;
@end

@implementation APPContentTopBarVideoListController

- (id)init
{
    self = [super init];
    if (self) {
        self.subtopbarWasVisible = TRUE;
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // save state of header form
            if ([self.tableViewHeaderFormView isHeaderShown]) {
                [self setSubtopbarWasVisible:TRUE];
            } else {
                [self setSubtopbarWasVisible:FALSE];
            }
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        }];
        
        [[self configureState:tActiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // show header form if was visible
            if (self.subtopbarWasVisible) {
                [self.tableViewHeaderFormView showOnCompletion:nil animated:NO];
            }
        }];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];
}

-(BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView*)view
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
}

@end