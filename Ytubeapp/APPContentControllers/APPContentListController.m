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
        self.dataCache = [[APPGlobals classInstance] getGlobalForKey:@"dataCache"];
        
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toDefaultShowMode];
        }];

        [[self configureState:tClearState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView clearView];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloadedFinished:) name:eventDataReloadedFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloadedError:) name:eventDataReloadedError object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataMoreLoadedFinished:) name:eventDataMoreLoadedFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataMoreLoadedError:) name:eventDataMoreLoadedError object:nil];
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

-(APPTableCell *)tableView:(UITableView *)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(int)tableView:(UITableView*)tableView forMode:(NSString*)mode numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataCache getData:mode] count];
}

-(void)tableView:(UITableView *)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)tableView:(UITableView *)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(BOOL)hasData:(NSString*)key
{
    return [self.dataCache hasData:key];
}

-(void)reloadData:(NSString*)key
{
    [self.dataCache reloadData:key withContext:self.tableView];
}

-(void)loadMoreData:(NSString*)key
{
    [self.dataCache loadMoreData:key withContext:self.tableView];
}

-(void)clearData:(NSString*)key
{
    [self.dataCache clearData:key];
}

-(void)dataReloadedFinished:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableView dataReloadedFinished:key];
    }
}

-(void)dataReloadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    [self.dataCache clearData:key];
    if (self.tableView == tableView) {
        [self.tableView dataReloadedError:key];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                    message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)loadedMoreFinished:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableView loadedMoreFinished:key];
    }
}

-(void)loadedMoreError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    if (self.tableView == tableView) {
        [self.tableView loadedMoreError:key];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                    message:[NSString stringWithFormat:@"Unable to load more data. Please try again later."]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(NSString*)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState]) return nil;
    return indexPath;
}

-(BOOL)tableViewCanBottom:(UITableView*)view
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
}

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    if ([self inState:tPassiveState]) return FALSE;
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

-(APPSelectDelegateCallback)afterSelect {
    return ^(GDataEntryBase *entryBase) {
    };
}

-(void)setAfterSelect:(APPSelectDelegateCallback)afterSelect {
}

@end