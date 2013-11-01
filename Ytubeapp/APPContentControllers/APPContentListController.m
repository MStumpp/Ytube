//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentListController.h"

@interface APPContentListController()
@property NSIndexPath *openSubMenuCell;
@end

@implementation APPContentListController

-(id)init
{
    self = [super init];
    if (self) {
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toDefaultShowMode];
        }];
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // close open cell if one is open
            if ([self.tableView openCell]) {
                self.openSubMenuCell = [self.tableView openCell];
                [self.tableView closeCell:[self.tableView openCell] onCompletion:nil];
            } else {
                self.openSubMenuCell = nil;
            }
        }];
        
        [[self configureState:tActiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // open cell if one was opened
            if (self.openSubMenuCell) {
                [self.tableView openCell:self.openSubMenuCell onCompletion:nil];
            }
        }];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.tableView = [[APPTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44.0) style:UITableViewStylePlain];
    self.tableView._del = self;
    [self.view addSubview:self.tableView];
}

// APPTableViewDelegate

-(CGFloat)tableView:(UITableView*)tableView forMode:(NSString*)mode heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 88.0;
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(int)tableView:(UITableView*)tableView forMode:(NSString*)mode numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataCache hasData:mode])
        return [[self.dataCache getData:mode] count];
    else
        return 0;
}

-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(NSString*)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState]) return nil;
    return indexPath;
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return FALSE;
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
}

-(BOOL)tableView:(UITableView*)tableView canOpenCellforMode:(NSString*)mode forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
}

-(BOOL)hasData:(NSString*)key
{
    return [self.dataCache hasData:key];
}

-(BOOL)canLoadMoreData:(NSString*)key
{
    return [self.dataCache canLoadMoreData:key];
}

-(void)reloadData:(NSString*)key
{
    [self.dataCache reloadData:key withContext:self.tableView];
}

-(void)loadMoreData:(NSString*)key
{
    if ([self.dataCache canLoadMoreData:key])
        [self.dataCache loadMoreData:key withContext:self.tableView];
}

-(void)clearData:(NSString*)key
{
    [self.dataCache clearData:key];
}

-(void)dataReloadedFinished:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableView dataReloadedFinished:key];
    }
}

-(void)dataReloadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
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

-(void)dataMoreLoadedFinished:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableView loadedMoreFinished:key];
    }
}

-(void)dataMoreLoadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if (self.tableView == tableView) {
        [self.tableView loadedMoreError:key];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                    message:[NSString stringWithFormat:@"Unable to load more data. Please try again later."]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
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
}

-(void)afterShowModeChange
{
}

-(NSNumber*)keyToNumber:(NSString*)key
{
    return [self.keyConvert objectForKey:key];
}

-(NSString*)keyToString:(NSNumber*)key
{
    NSArray *keys = [self.keyConvert allKeysForObject:key];
    if ([keys count] > 0) return keys[0];
    return NULL;
}

@end