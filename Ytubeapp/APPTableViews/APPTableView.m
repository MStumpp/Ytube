//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPTableView.h"
#import "MBProgressHUD.h"
#import "QueryTicket.h"

#define tDefaultShowMode 10

@interface APPTableView()
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) UITableViewSwipeView *tableViewSwipeView;
@property (nonatomic, strong) UITableViewAtBottomView *tableViewAtBottomView;
@property (nonatomic, strong) UITableViewMaskView *tableViewMaskView;
@property (nonatomic, strong) NSIndexPath *openCell;
@property int showMode;
@property (strong, nonatomic) NSMutableDictionary *queryTicketsReload;
@property (strong, nonatomic) NSMutableDictionary *queryTicketsLoadMore;
@property (strong, nonatomic) NSMutableDictionary *feeds;
@property (strong, nonatomic) NSMutableDictionary *customFeeds;
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

        self.queryTicketsReload = [NSMutableDictionary alloc];
        self.queryTicketsLoadMore = [NSMutableDictionary alloc];
        self.feeds = [NSMutableDictionary alloc];
        self.customFeeds = [NSMutableDictionary alloc];
        [self addShowMode:tDefaultShowMode];
    }
    return self;
}

// UITableView stuff

#pragma mark - Table view data source

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPTableCell *cell = [self._delegate tableView:tableView forMode:self.showMode cellForRowAtIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.tableView = self;
    // ensure cell is either open or closed
    if (self.openCell && [self.openCell row] == [indexPath row])
        [cell openOnCompletion:nil animated:NO];
    else
        [cell closeOnCompletion:nil animated:NO];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self currentCustomFeedForShowMode:self.showMode])
        return [[self currentCustomFeedForShowMode:self.showMode] count];
    else
        return 0;
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
        return [self._delegate tableView:tableView forMode:self.showMode willSelectRowAtIndexPath:indexPath];
    else
        return nil;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self._delegate tableView:tableView forMode:self.showMode didSelectRowAtIndexPath:indexPath];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self._delegate tableView:tableView canEditRowAtIndexPath:indexPath];

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
    [self._delegate tableView:tableView forMode:self.showMode
           commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

// "UITableViewAtBottomViewDelegate" Protocol

-(BOOL)tableViewCanBottom:(UITableView*)view
{
    if ([self._delegate respondsToSelector:@selector(tableViewCanBottom:)])
        return [self._delegate tableViewCanBottom:view];
    return YES;
}

-(void)tableViewDidBottom:(UITableView*)view
{
    [self loadMoreDataForShowMode:self.showMode withPrio:tVisibleload];
}

// "SSPullToRefreshViewDelegate" Protocol

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    if ([self._delegate respondsToSelector:@selector(pullToRefreshViewShouldStartLoading:)])
        return [self._delegate pullToRefreshViewShouldStartLoading:view];
    return YES;
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

    // if there is

    if (!error) {

        // replace current feed for mode
        [self currentFeed:feed forShowMode:mode];

        // init custom feed array, either initialize fresh array or clear
        if (![self currentCustomFeedForShowMode:mode]) {
            [self currentCustomFeed:[NSMutableArray array] forShowMode:mode];
        } else {
            [[self currentCustomFeedForShowMode:mode] removeAllObjects];
        }

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
    if (!mode || mode == tDefaultShowMode || [self hasShowMode:mode])
        return FALSE;
    [self.queryTicketsReload addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.queryTicketsLoadMore addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.feeds addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.customFeeds addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSMutableArray array] forKey:[NSNumber numberWithInt:mode]]];

    // remove tDefaultShowMode in dicts once one custom show mode is added
    [self.queryTicketsReload removeObjectForKey:[NSNumber numberWithInt:tDefaultShowMode]];
    [self.queryTicketsLoadMore removeObjectForKey:[NSNumber numberWithInt:tDefaultShowMode]];
    [self.feeds removeObjectForKey:[NSNumber numberWithInt:tDefaultShowMode]];
    [self.customFeeds removeObjectForKey:[NSNumber numberWithInt:tDefaultShowMode]];

    return TRUE;
}

-(void)toShowMode:(int)mode
{
    if (!mode || ![self hasShowMode:mode])
        [NSException raise:@"show mode is nil or doesn't exists" format:@"show mode is nil or doesn't exists"];

    // if current show mode equal to requested show mode, then just scroll to top
    if (self.showMode == mode) {
        [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }

    // do some exit processing
    if ([self._delegate respondsToSelector:@selector(beforeShowModeChange)])
        [self._delegate beforeShowModeChange];

    self.showMode = mode;

    // do some enter processing
    if ([self._delegate respondsToSelector:@selector(afterShowModeChange)])
        [self._delegate afterShowModeChange];

    QueryTicket *ticket = [self queryTicketForMode:mode forType:self.queryTicketsReload];
    // if there is no ticket, load the data for the first time
    if (!ticket)
        [self reloadDataForShowMode:mode withPrio:tVisibleload];
    // otherwise, just reload the data
    else
        [self reloadData];
}

-(int)showMode
{
    return self.showMode;
}

-(void)reloadDataAll
{
    // reset all show modes
    [self resetAllShowModesAndReload];
    // load initial data for each show mode
    NSArray* keys = [self.queryTicketsReload allKeys];
    for(NSNumber* key in keys)
        [self reloadDataForShowMode:[key intValue] withPrio:tVisibleload];
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
    QueryTicket *ticket = [self._delegate tableView:self reloadDataConcreteForShowMode:mode
                                           withPrio:prio];
    [self setQueryTicket:ticket forMode:mode forType:self.queryTicketsReload];
}

-(void)loadMoreDataForShowMode:(int)mode withPrio:(int)prio
{
    // if there is no feed, cant load more data
    if (![self currentFeedForShowMode:mode])
        return;

    // eventually cancel currently running load more request
    if ([self queryTicketForMode:mode forType:self.queryTicketsLoadMore])
        [[self queryTicketForMode:mode forType:self.queryTicketsLoadMore] cancel];

    // load more data
    QueryTicket *ticket = [self._delegate tableView:self loadMoreDataConcreteForShowMode:mode
                                            forFeed:[self currentFeedForShowMode:mode] withPrio:prio];
    [self setQueryTicket:ticket forMode:mode forType:self.queryTicketsLoadMore];
}

-(BOOL)resetShowMode:(int)mode
{
    if ([self hasShowMode:mode])
        return FALSE;
    if ([self queryTicketForMode:mode forType:self.queryTicketsReload])
        [[self queryTicketForMode:mode forType:self.queryTicketsReload] cancel];
    [self.queryTicketsReload setObject:nil forKey:[NSNumber numberWithInt:mode]];

    if ([self queryTicketForMode:mode forType:self.queryTicketsLoadMore])
        [[self queryTicketForMode:mode forType:self.queryTicketsLoadMore] cancel];
    [self.queryTicketsLoadMore setObject:nil forKey:[NSNumber numberWithInt:mode]];

    [self.feeds setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [[self currentCustomFeedForShowMode:mode] removeAllObjects];
}

-(void)resetAllShowModes
{
    NSArray* keys = [self.queryTicketsReload allKeys];
    for(NSNumber* key in keys)
        [self resetShowMode:[key intValue]];
}

-(void)resetAllShowModesAndReload
{
    NSArray* keys = [self.queryTicketsReload allKeys];
    for(NSNumber* key in keys)
        [self resetShowMode:[key intValue]];
    [self reloadData];
}

-(void)setQueryTicket:(QueryTicket*)ticket forMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (ticket && mode && type)
        [type setObject:ticket forKey:[NSNumber numberWithInt:mode]];
}

-(QueryTicket*)queryTicketForMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode)
        return (QueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]];
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
    NSArray* keys = [self.queryTicketsReload allKeys];
    for(NSNumber* key in keys)
        if ([key intValue] == mode) return TRUE;
    return FALSE;
}

@end