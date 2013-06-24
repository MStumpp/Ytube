//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPTableView.h"
#import "MBProgressHUD.h"
#import "QueryTicket.h"

typedef void(^APPTableViewCallback)();

@interface APPTableView()
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) UITableViewSwipeView *tableViewSwipeView;
@property (nonatomic, strong) UITableViewAtBottomView *tableViewAtBottomView;
@property (nonatomic, strong) UITableViewMaskView *tableViewMaskView;
@property (nonatomic, strong) NSIndexPath *openCell;
@property int showMode;
@property (strong, nonatomic) NSMutableDictionary *reloadDataQueryTickets;
@property (strong, nonatomic) NSMutableDictionary *loadMoreDataQueryTickets;
@property (strong, nonatomic) NSMutableDictionary *feeds;
@property (strong, nonatomic) NSMutableDictionary *customFeeds;
@property (nonatomic, copy) APPTableViewCallback callback;
@end

@implementation APPTableView
@synthesize pullToRefreshView;
@synthesize tableViewSwipeView;
@synthesize tableViewAtBottomView;
@synthesize openCell;
@synthesize showMode;
@synthesize reloadDataQueryTickets;
@synthesize loadMoreDataQueryTickets;
@synthesize feeds;
@synthesize customFeeds;

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

        self.reloadDataQueryTickets = [NSMutableDictionary dictionary];
        self.loadMoreDataQueryTickets = [NSMutableDictionary dictionary];
        self.feeds = [NSMutableDictionary dictionary];
        self.customFeeds = [NSMutableDictionary dictionary];
    }
    return self;
}

// UITableView stuff

#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTableCell *cell = [self._delegate tableView:tableView forMode:self.showMode cellForRowAtIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.tableView = self;
    if (self.openCell && [self.openCell row] == [indexPath row])
        [cell openOnCompletion:nil animated:NO];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self currentCustomFeed])
        return [[self currentCustomFeed] count];
    else
        return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}

#pragma mark - Table view delegate

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPTableCell *selectedCell = (APPTableCell*) [self cellForRowAtIndexPath:indexPath];
    if (![selectedCell isOpened])
        return indexPath;
    else
        return nil;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self._delegate tableView:tableView forMode:self.showMode didSelectRowAtIndexPath:(NSIndexPath*)indexPath];
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self._delegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
        return [self._delegate tableView:tableView canEditRowAtIndexPath:indexPath];
    return YES;

    //    if (self.tmpEditingCell) {
    //        if ([self.tmpEditingCell row] == [indexPath row])
    //            return TRUE;
    //        else
    //            return FALSE;
    //    } else {
    //        return TRUE;
    //    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self._delegate tableView:tableView forMode:self.showMode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath];
}

// "UITableViewAtBottomViewDelegate" Protocol

-(BOOL)tableViewCanBottom:(UITableView *)view
{
    if ([self._delegate respondsToSelector:@selector(tableViewCanBottom:)])
        return [self._delegate tableViewCanBottom:view];
    return YES;
}

-(void)tableViewDidBottom:(UITableView *)view
{
    [self loadMoreDataForShowMode:self.showMode withPrio:tVisibleload];
}

// "SSPullToRefreshViewDelegate" Protocol

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view
{
    if ([self._delegate respondsToSelector:@selector(pullToRefreshViewShouldStartLoading:)])
        return [self._delegate pullToRefreshViewShouldStartLoading:view];
    return YES;
}

-(void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self.pullToRefreshView startLoading];
    [self reloadDataForShowMode:self.showMode withPrio:tVisibleload];
}

// TODO: Possibly move that to UITableCell
// "UITableViewSwipeViewDelegate" Protocol

-(void)tableViewSwipeViewDidSwipeLeft:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath
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

-(void)tableViewSwipeViewDidSwipeRight:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath
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

// reloads data
-(void)reloadShowMode
{

}

-(void)reloadDataForShowMode:(int)mode withPrio:(int)prio
{
    // eventually cancel query ticket querying more data
    [[self queryTicketForMode:mode forType:self.loadMoreDataQueryTickets] cancel];
    [self setQueryTicket:nil forMode:mode forType:self.loadMoreDataQueryTickets];

    switch ([self stateForShowMode:mode forType:self.reloadDataQueryTickets])
    {
        // if there is a ticket and its state is unloaded, eventually adjust prio
        case tUnloaded:
        {
            if ([self prioForShowMode:mode forType:self.reloadDataQueryTickets] != prio)
                [self setPrio:prio forShowMode:mode forType:self.reloadDataQueryTickets];
            break;
        }

            // if there is a ticket and its state is loading, eventually adjust prio
        case tLoading:
        {
            if ([self prioForShowMode:mode forType:self.reloadDataQueryTickets] != prio)
                [self setPrio:prio forShowMode:mode forType:self.reloadDataQueryTickets];
            break;
        }

            // if there is no ticket yet or ticket is in state tLoaded or tCancelled
            // make a new request and store returned ticket
        default:
        {
            [self setQueryTicket:[self._delegate tableView:self reloadDataConcreteForShowMode:mode withPrio:prio] forMode:mode forType:self.reloadDataQueryTickets];
            break;
        }
    }
}

-(void)reloadDataResponse:(NSDictionary*)args
{
    int mode = [[args objectForKey:tMode] intValue];
    if (![args objectForKey:tError]) {

        // replace current feed for mode
        [self currentFeed:[args objectForKey:tFeed] forShowMode:mode];

        // init custom feed array, either initialize array or clear
        if (![self currentCustomFeedForShowMode:mode]) {
            [self currentCustomFeed:[NSMutableArray array] forShowMode:mode];

        } else {
            [[self currentCustomFeedForShowMode:mode] removeAllObjects];
        }

        // finally, add feed entries to custom feed
        [[self currentCustomFeedForShowMode:mode] addObjectsFromArray:[[args objectForKey:tFeed] entries]];

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

-(void)loadMoreDataForShowMode:(int)mode withPrio:(int)prio
{
    switch ([self stateForShowMode:mode forType:self.loadMoreDataQueryTickets])
    {
        // if there is a ticket and its state is unloaded, eventually adjust prio
        case tUnloaded:
        {
            if ([self prioForShowMode:mode forType:self.loadMoreDataQueryTickets] != prio)
                [self setPrio:prio forShowMode:mode forType:self.loadMoreDataQueryTickets];
            break;
        }

            // if there is a ticket and its state is loading, eventually adjust prio
        case tLoading:
        {
            if ([self prioForShowMode:mode forType:self.loadMoreDataQueryTickets] != prio)
                [self setPrio:prio forShowMode:mode forType:self.loadMoreDataQueryTickets];
            break;
        }

            // if there is no ticket yet or ticket is in state tLoaded or tCancelled
            // make a new request and store returned ticket
        default:
        {
            if ([self currentFeedForShowMode:mode])
                [self setQueryTicket:[self._delegate tableView:self loadMoreDataConcreteForShowMode:mode forFeed:[self currentFeedForShowMode:mode] withPrio:prio] forMode:mode forType:self.reloadDataQueryTickets];
            break;
        }
    }
}

-(void)loadMoreDataResponse:(NSDictionary*)args
{
    int mode = [[args objectForKey:tMode] intValue];
    if (![args objectForKey:tError]) {

        // replace current feed for mode
        [self currentFeed:[args objectForKey:tFeed] forShowMode:mode];

        // finally, add feed entries to custom feed
        [[self currentCustomFeedForShowMode:mode] addObjectsFromArray:[[args objectForKey:tFeed] entries]];

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

-(void)toShowMode:(int)mode
{
    if (!mode || (self.showMode && self.showMode == mode))
        return;

    if ([self._delegate respondsToSelector:@selector(beforeShowModeChange)])
        [self._delegate beforeShowModeChange];

    self.showMode = mode;

    if ([self._delegate respondsToSelector:@selector(afterShowModeChange)])
        [self._delegate afterShowModeChange];

    switch ([self stateForShowMode:self.showMode forType:self.reloadDataQueryTickets])
    {
        // state of showmmode is loaded, just display it
        case tLoaded:
        {
            [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
                if (isUnmasked) {
                    [self.pullToRefreshView finishLoading];
                    [self reloadData];
                }
            }];
            break;
        }

            // otherwise, if state of showmode is tUnloaded, tLoading or tCancelled,
            // call reloadDataOfShowMode with prio set to highest
        default:
        {
            [self.tableViewMaskView maskOnCompletion:^(BOOL isMasked) {
                if (isMasked) {
                    [self reloadDataForShowMode:mode withPrio:tVisibleload];
                }
            }];
            break;
        }
    }
}

-(void)addShowMode:(int)mode
{
    [self.reloadDataQueryTickets addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.loadMoreDataQueryTickets addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.feeds addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.customFeeds addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
}

-(void)resetAllShowModes
{
    NSArray* keys = [self.reloadDataQueryTickets allKeys];
    for(NSNumber* key in keys)
        [self resetShowMode:[key intValue]];
}

-(void)resetShowMode:(int)mode
{
    [self.reloadDataQueryTickets setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [self.loadMoreDataQueryTickets setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [self.feeds setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [self.customFeeds setObject:nil forKey:[NSNumber numberWithInt:mode]];
}

-(int)showMode
{
    return self.showMode;
}

-(GDataFeedBase*)currentFeed
{
    return [self currentFeedForShowMode:self.showMode];
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

-(NSMutableArray*)currentCustomFeed
{
    return [self currentCustomFeed:nil forShowMode:self.showMode];
}

-(NSMutableArray*)currentCustomFeedForShowMode:(int)mode
{
    return [self currentCustomFeed:nil forShowMode:mode];
}

-(NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed forShowMode:(int)mode
{
    if (feed)
        [self.customFeeds setObject:feed forKey:[NSNumber numberWithInt:mode]];
    return (NSMutableArray*)[self.customFeeds objectForKey:[NSNumber numberWithInt:mode]];
}

-(int)stateForShowMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode && type && [type objectForKey:[NSNumber numberWithInt:mode]])
        return [(QueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]] state];
    else
    return -1;
}

-(int)prioForShowMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode && type && [type objectForKey:[NSNumber numberWithInt:mode]])
        return [(QueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]] prio];
    else
    return -1;
}

-(void)setPrio:(int)prio forShowMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (prio && mode && type && [type objectForKey:[NSNumber numberWithInt:mode]])
        [(QueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]] setPrio:prio];
}

-(QueryTicket*)queryTicketForMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode && type)
        return (QueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]];
}

-(void)setQueryTicket:(QueryTicket*)ticket forMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (ticket && mode && type)
        [type setObject:ticket forKey:[NSNumber numberWithInt:mode]];
}

@end