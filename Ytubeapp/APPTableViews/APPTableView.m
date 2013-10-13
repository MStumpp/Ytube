//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPTableView.h"
#import "MBProgressHUD.h"
#import "APPAbstractQuery.h"
#import "APPGlobals.h"

#define tDefaultShowMode @"defaultShowMode"

@interface APPTableView()
@property SSPullToRefreshView *pullToRefreshView;
@property UITableViewSwipeView *tableViewSwipeView;
@property UITableViewAtBottomView *tableViewAtBottomView;
@property UITableViewMaskView *tableViewMaskView;
@property NSIndexPath *openCell;
@property NSString *defaultShowMode;
@property NSMutableArray *showModes;
@end

@implementation APPTableView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        self.delegate = self;
        self.dataSource = self;

        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self clearsContextBeforeDrawing];

        self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self delegate:self];
        self.tableViewSwipeView = [[UITableViewSwipeView alloc] initWithTableView:self delegate:self];
        self.tableViewAtBottomView = [[UITableViewAtBottomView alloc] initWithTableView:self delegate:self];
        self.tableViewMaskView = [[UITableViewMaskView alloc] initWithRootView:self customMaskView:nil delegate:self];
        
        self.showModes = [NSMutableArray new];

        [self addDefaultShowMode:tDefaultShowMode];
    }
    return self;
}

// UITableView stuff

#pragma mark - Table view data source

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.showMode) {
        APPTableCell *cell = [self._del tableView:tableView forMode:self.showMode cellForRowAtIndexPath:indexPath];
        cell.indexPath = indexPath;
        cell.__tableView = self;
        // ensure cell is either open or closed
        if (self.openCell && [self.openCell row] == [indexPath row])
            [cell openOnCompletion:nil animated:NO];
        else
            [cell closeOnCompletion:nil animated:NO];
        return cell;

    } else {
        return nil;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showMode) {
        return [self._del tableView:tableView forMode:self.showMode numberOfRowsInSection:section];
    } else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 88.0;
}

#pragma mark - Table view delegate

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPTableCell *selectedCell = (APPTableCell*) [self cellForRowAtIndexPath:indexPath];
    if (![selectedCell isOpened])
        return [self._del tableView:tableView forMode:self.showMode willSelectRowAtIndexPath:indexPath];
    else
        return nil;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self._del tableView:tableView forMode:self.showMode didSelectRowAtIndexPath:indexPath];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TRUE;

    //return [self._del tableView:tableView canEditRowAtIndexPath:indexPath];

    //    if (self.tmpEditingCell) {
    //        if ([self.tmpEditingCell row] == [indexPath row])
    //            return TRUE;
    //        else
    //            return FALSE;
    //    } else {
    //        return TRUE;
    //    }
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self._del tableView:tableView forMode:self.showMode
           commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

// "UITableViewAtBottomViewDelegate" Protocol

-(BOOL)tableViewCanBottom:(UITableView*)view
{
    return [self._del tableViewCanBottom:view];
}

-(void)tableViewDidBottom:(UITableView*)view
{
    [self loadMoreDataForShowMode:self.showMode];
}

// "SSPullToRefreshViewDelegate" Protocol

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    return [self._del pullToRefreshViewShouldStartLoading:view];
}

-(void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [self.pullToRefreshView startLoading];
    [self reloadDataForShowMode:self.showMode];
}

// "UITableViewSwipeViewDelegate" Protocol

-(void)tableViewSwipeViewDidSwipeLeft:(UITableView*)view rowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"tableViewSwipeViewDidSwipeLeft");
    APPTableCell *cell = (APPTableCell*) [self cellForRowAtIndexPath:indexPath];
    // if there is an open cell, close this first, then open the requested cell
    if (self.openCell) {
        if ([self.openCell row] == [indexPath row])
            return;

        APPTableCell *currentOpenCell = (APPTableCell*) [self cellForRowAtIndexPath:self.openCell];
        [currentOpenCell closeOnCompletion:^(BOOL isClosed) {
            if (isClosed) {
                [cell openOnCompletion:^(BOOL isOpened) {
                    if (isOpened)
                        self.openCell = indexPath;
                } animated:YES];
            }
        } animated:YES];

    // open the requested cell
    } else {
        [cell openOnCompletion:^(BOOL isOpened) {
            if (isOpened)
                self.openCell = indexPath;
        } animated:YES];
    }

//    APPTableCell *cell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
//    if ([cell isClosed] && self.tmpEditingCell && [self.tmpEditingCell row] == [indexPath row]) {
//        self.tmpEditingCell = nil;
//        [self.tableView setEditing:NO animated:YES];
//
//    } else {
//        [super tableViewSwipeViewDidSwipeLeft:view rowAtIndexPath:indexPath];
//    }
}

-(void)tableViewSwipeViewDidSwipeRight:(UITableView*)view rowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"tableViewSwipeViewDidSwipeRight");
    APPTableCell *cell = (APPTableCell*) [self cellForRowAtIndexPath:indexPath];
    [cell closeOnCompletion:^(BOOL isClosed) {
        if (isClosed) {
            self.openCell = nil;
        }
    } animated:YES];

//    APPTableCell *cell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
//    if (![self.tableView isEditing] && [cell isClosed] && !self.tmpEditingCell) {
//        self.tmpEditingCell = indexPath;
//        [self.tableView setEditing:YES animated:YES];
//
//    } else if ([self.tableView isEditing] && [cell isClosed] && self.tmpEditingCell && [self.tmpEditingCell row] != [indexPath row]) {
//        self.tmpEditingCell = indexPath;
//        [self.tableView setEditing:NO animated:YES];
//        [self.tableView setEditing:YES animated:YES];
//
//    } else {
//        [super tableViewSwipeViewDidSwipeRight:view rowAtIndexPath:indexPath];
//    }
}

-(BOOL)addShowMode:(NSString*)mode
{
    if (!mode || [self hasShowMode:mode]) return FALSE;
    [self.showModes addObject:mode];
    return TRUE;
}

-(BOOL)addDefaultShowMode:(NSString*)mode
{
    if (!mode || [self hasShowMode:mode]) return FALSE;
    self.defaultShowMode = mode;
    return [self addShowMode:mode];
}

-(void)toShowMode:(NSString*)mode
{
    //NSLog(@"toShowMode %@", mode);
    
    if (!mode || ![self hasShowMode:mode])
        [NSException raise:@"show mode is nil or doesn't exists" format:@"show mode is nil or doesn't exists"];

    // if current show mode equal to requested show mode, then just scroll to top
    if (self.showMode == mode) {
        //[self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }

    // do some exit processing
    [self._del beforeShowModeChange];

    self.showMode = mode;

    // show or reload
    [self._del afterShowModeChange];

    if ([self._del hasData:mode]) {
        [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
            if (isUnmasked) {
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }];

    } else {
        [self.tableViewMaskView maskOnCompletion:^(BOOL isMasked) {
            if (isMasked) {
                [self reloadDataForShowMode:mode];
            }
        }];
    }
}

-(void)toDefaultShowMode
{
    [self toShowMode:self.defaultShowMode];
}

-(void)clearView
{
    // reset all show modes
    [self resetAllShowModesAndClear];
}

-(void)clearViewAndReloadAll
{
    [self clearView];
    // load initial data for current show mode
    [self reloadDataForShowMode:self.showMode];
}

-(void)dataReloadedFinished:(NSString*)mode
{
    if (mode == self.showMode) {
        [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
            if (isUnmasked) {
                [self.pullToRefreshView finishLoading];
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

-(void)dataReloadedError:(NSString*)mode
{
    [self._del clearData:mode];
    if (mode == self.showMode) {
        [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
            if (isUnmasked) {
                [self.pullToRefreshView finishLoading];
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

-(void)loadedMoreFinished:(NSString*)mode
{
    if (mode == self.showMode) {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

-(void)loadedMoreError:(NSString*)mode
{
}

// private

-(void)reloadDataForShowMode:(NSString*)mode
{
    [self._del reloadData:mode];
}

-(void)loadMoreDataForShowMode:(NSString*)mode
{
    [self._del loadMoreData:mode];
}

-(void)resetAllShowModesAndClear
{
    for (NSString* mode in self.showModes) {
        [self._del clearData:mode];
    }
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(BOOL)hasShowMode:(NSString*)mode
{
    for (NSString* tmp in self.showModes) {
        if ([tmp isEqualToString:mode]) {
            return TRUE;
        }
    }
    return FALSE;
}

@end