//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentListController.h"

@implementation APPContentListController

-(id)init
{
    self = [super init];
    if (self) {
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toDefaultShowMode];
        }];

        [[self configureState:tClearState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView clearView];
        }];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.tableView = [[APPTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height-44.0) style:UITableViewStylePlain];
    self.tableView._del = self;
    [self.view addSubview:self.tableView];
}

// APPTableViewDelegate

- (APPTableCell *)tableView:(UITableView *)tableView forMode:(int)mode cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView forMode:(int)mode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView forMode:(int)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (Query *)tableView:(APPTableView *)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p {
    return nil;
}

- (Query *)tableView:(APPTableView *)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase *)feed withPrio:(int)p {
    return nil;
}

-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(int)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState])
        return nil;

    return indexPath;
}

-(BOOL)tableViewCanBottom:(UITableView*)view
{
    if ([self inState:tPassiveState])
        return FALSE;

    return TRUE;
}

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    if ([self inState:tPassiveState])
        return FALSE;

    return TRUE;
}

-(void)beforeShowModeChange
{
    return;
}

-(void)afterShowModeChange
{
    return;
}

// SelectDelegate

- (APPSelectDelegateCallback)afterSelect {
    return ^(GDataEntryBase *entryBase) {
    };
}

- (void)setAfterSelect:(APPSelectDelegateCallback)afterSelect {

}

@end