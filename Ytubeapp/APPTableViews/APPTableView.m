//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPTableView.h"
#import "MBProgressHUD.h"
#import "APPAbstractQuery.h"

#define tDefaultShowMode -1

@interface APPTableView()
@property SSPullToRefreshView *pullToRefreshView;
@property UITableViewSwipeView *tableViewSwipeView;
@property UITableViewAtBottomView *tableViewAtBottomView;
@property UITableViewMaskView *tableViewMaskView;
@property NSIndexPath *openCell;
@property int defaultShowMode;
@property NSMutableDictionary *queriesReload;
@property NSMutableDictionary *queriesLoadMore;
@property NSMutableDictionary *feeds;
@property NSMutableDictionary *customFeeds;
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
        UIView *progressView = [[UIView alloc] init];
        [MBProgressHUD showHUDAddedTo:progressView animated:YES];
        [self.tableViewMaskView setCustomMaskView:progressView];

        self.queriesReload = [[NSMutableDictionary alloc] init];
        self.queriesLoadMore = [[NSMutableDictionary alloc] init];
        self.feeds = [[NSMutableDictionary alloc] init];
        self.customFeeds = [[NSMutableDictionary alloc] init];

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
        if ([self currentCustomFeedForShowMode:self.showMode]) {
            return [[self currentCustomFeedForShowMode:self.showMode] count];
        } else {
            return 0;
        }

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
    [self loadMoreDataForShowMode:self.showMode withPrio:tVisibleload];
}

// "SSPullToRefreshViewDelegate" Protocol

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    return [self._del pullToRefreshViewShouldStartLoading:view];
}

-(void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView*)view
{
    [self.pullToRefreshView startLoading];
    [self reloadDataForShowMode:self.showMode withPrio:tVisibleload];
}

// TODO: Possibly move that to UITableCell
// "UITableViewSwipeViewDelegate" Protocol

-(void)tableViewSwipeViewDidSwipeLeft:(UITableView*)view rowAtIndexPath:(NSIndexPath*)indexPath
{
    APPTableCell *cell = (APPTableCell*) [self cellForRowAtIndexPath:indexPath];
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

// "APPTableViewProcessResponse" Protocol

-(void)reloadDataResponse:(NSDictionary*)args
{
    int mode = [[args objectForKey:tMode] intValue];
    GDataFeedBase *feed = [args objectForKey:tFeed];
    NSError *error = [args objectForKey:tError];

    // if there is no error

    if (!error) {

        // replace current feed for mode
        [self currentFeed:feed forShowMode:mode];

        // clear custom feed array
        [[self currentCustomFeedForShowMode:mode] removeAllObjects];

        // finally, add feed entries to custom feed
        [[self currentCustomFeedForShowMode:mode] addObjectsFromArray:[feed entries]];

        // if show mode of response is equal to current show mode,
        // update shown data
        if (mode == self.showMode)
        {
            [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
                if (isUnmasked) {
                    [self.pullToRefreshView finishLoading];
                    [self reloadData];
                }
            }];
        }

    } else {

        [self resetShowMode:mode];
        if (mode == self.showMode)
        {
            [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
                if (isUnmasked) {
                    [self.pullToRefreshView finishLoading];
                    [self reloadData];
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"We could not reload your data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            }];
        }
    }
}

-(void)loadMoreDataResponse:(NSDictionary*)args
{
    int mode = [[args objectForKey:tMode] intValue];
    GDataFeedBase *feed = [args objectForKey:tFeed];
    NSError *error = [args objectForKey:tError];

    if (!error) {

        // replace current feed for mode
        [self currentFeed:feed forShowMode:mode];

        // finally, add feed entries to custom feed
        [[self currentCustomFeedForShowMode:mode] addObjectsFromArray:[feed entries]];

        // if show mode of response is equal to current show mode,
        // update shown data
        if (mode == self.showMode)
        {
            [self reloadData];
        }

    } else {

        if (mode == self.showMode)
        {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"We could not reload your data. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }
}

-(BOOL)addShowMode:(int)mode
{
    if (!mode || [self hasShowMode:mode])
        return FALSE;
    [self.queriesReload setObject:[NSNull new] forKey:[NSNumber numberWithInt:mode]];
    [self.queriesLoadMore setObject:[NSNull new] forKey:[NSNumber numberWithInt:mode]];
    [self.feeds setObject:[NSNull new] forKey:[NSNumber numberWithInt:mode]];
    [self.customFeeds setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:mode]];
    return TRUE;
}

-(BOOL)addDefaultShowMode:(int)mode
{
    if (!mode || [self hasShowMode:mode])
        return FALSE;
    self.defaultShowMode = mode;
    return [self addShowMode:mode];
}

-(void)toShowMode:(int)mode
{
    NSLog(@"toShowMode %i", mode);
    if (!mode || ![self hasShowMode:mode])
        [NSException raise:@"show mode is nil or doesn't exists" format:@"show mode is nil or doesn't exists"];

    // if current show mode equal to requested show mode, then just scroll to top
    if (self.showMode == mode) {
        NSLog(@"testtesttest");
        [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }

    // do some exit processing
    [self._del beforeShowModeChange];

    self.showMode = mode;

    // do some enter processing
    [self._del afterShowModeChange];

    Query *query = [self queryForMode:mode forType:self.queriesReload];
    if ([self queryForMode:mode forType:self.queriesReload] &&
            [self queryForMode:mode forType:self.queriesReload] != (id)[NSNull new] &&
            [[self queryForMode:mode forType:self.queriesReload] isFinished] &&
            ![(APPAbstractQuery*)[self queryForMode:mode forType:self.queriesReload] hasError])
        [self reloadData];
    else
        [self reloadDataForShowMode:mode withPrio:tVisibleload];
}

-(void)toDefaultShowMode
{
    NSLog(@"toDefaultShowMode");
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
    // load initial data for each show mode
    NSArray* keys = [self.queriesReload allKeys];
    for(NSNumber* key in keys)
        [self reloadDataForShowMode:[key intValue] withPrio:tVisibleload];
}

-(NSMutableArray*)currentCustomFeed
{
    return [self currentCustomFeedForShowMode:self.showMode];
}

-(NSMutableArray*)currentCustomFeedForShowMode:(int)mode
{
    if (!mode || ![self hasShowMode:mode])
        [NSException raise:@"show mode is nil or doesn't exists" format:@"show mode is nil or doesn't exists"];
    return [self currentCustomFeed:nil forShowMode:mode];
}

// private

-(void)reloadDataForShowMode:(int)mode withPrio:(int)prio
{
    // reset show mode
    [self resetShowMode:mode];

    // reload the data
    Query *query = [self._del tableView:self reloadDataConcreteForShowMode:mode
                                           withPrio:prio];
    [self setQuery:query forMode:mode forType:self.queriesReload];
}

-(void)loadMoreDataForShowMode:(int)mode withPrio:(int)prio
{
    // if there is no feed, cant load more data
    if (![self currentFeedForShowMode:mode])
        return;

    // eventually cancel currently running load more request
    if ([self queryForMode:mode forType:self.queriesLoadMore] &&
            [self queryForMode:mode forType:self.queriesLoadMore] != (id)[NSNull new])
        [[self queryForMode:mode forType:self.queriesLoadMore] cancel];

    // load more data
    Query *query = [self._del tableView:self loadMoreDataConcreteForShowMode:mode
                                     forFeed:[self currentFeedForShowMode:mode] withPrio:prio];
    [self setQuery:query forMode:mode forType:self.queriesLoadMore];
}

-(void)resetAllShowModes
{
    NSArray* keys = [self.queriesReload allKeys];
    for(NSNumber* key in keys)
        [self resetShowMode:[key intValue]];
}

-(void)resetAllShowModesAndClear
{
    NSArray* keys = [self.queriesReload allKeys];
    for(NSNumber* key in keys)
        [self resetShowMode:[key intValue]];
    [self reloadData];
}

-(BOOL)resetShowMode:(int)mode
{
    if ([self queryForMode:mode forType:self.queriesReload] &&
            [self queryForMode:mode forType:self.queriesReload] != (id)[NSNull new])
        [[self queryForMode:mode forType:self.queriesReload] cancel];
    [self.queriesReload setObject:[NSNull new] forKey:[NSNumber numberWithInt:mode]];

    if ([self queryForMode:mode forType:self.queriesLoadMore] &&
            [self queryForMode:mode forType:self.queriesLoadMore] != (id)[NSNull new])
        [[self queryForMode:mode forType:self.queriesLoadMore] cancel];
    [self.queriesLoadMore setObject:[NSNull new] forKey:[NSNumber numberWithInt:mode]];

    [self.feeds setObject:[NSNull new] forKey:[NSNumber numberWithInt:mode]];
    [[self currentCustomFeedForShowMode:mode] removeAllObjects];
}

-(void)setQuery:(Query*)ticket forMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (ticket && mode && type)
        [type setObject:ticket forKey:[NSNumber numberWithInt:mode]];
}

-(Query*)queryForMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode)
        return (Query*)[type objectForKey:[NSNumber numberWithInt:mode]];
}

-(GDataFeedBase*)currentFeedForShowMode:(int)mode
{
    return [self currentFeed:nil forShowMode:mode];
}

-(GDataFeedBase*)currentFeed:(GDataFeedBase*)feed forShowMode:(int)mode
{
    if (feed)
        [self.feeds setObject:feed forKey:[NSNumber numberWithInt:mode]];
    return (GDataFeedBase*)[self.feeds objectForKey:[NSNumber numberWithInt:mode]];
}

-(NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed forShowMode:(int)mode
{
    if (feed)
        [self.customFeeds setObject:feed forKey:[NSNumber numberWithInt:mode]];
    return (NSMutableArray*)[self.customFeeds objectForKey:[NSNumber numberWithInt:mode]];
}

-(BOOL)hasShowMode:(int)mode
{
    NSArray* keys = [self.queriesReload allKeys];
    for(NSNumber* key in keys)
        if ([key intValue] == mode) return TRUE;
    return FALSE;
}

@end