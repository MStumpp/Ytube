//
//  APPSingleTableListViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 08.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableListViewController.h"
#import "MBProgressHUD.h"

typedef void(^APPSingleTableListViewControllerCallback)();

@interface APPSingleTableListViewController()
@property (nonatomic, copy) APPSingleTableListViewControllerCallback callback;
@end

@implementation APPSingleTableListViewController

@synthesize tableView;
@synthesize openCell;
@synthesize showMode;

@synthesize pullToRefreshView;
@synthesize tableViewSwipeView;
@synthesize tableViewAtBottomView;
@synthesize tableViewMaskView;

@synthesize reloadDataQueryTickets;
@synthesize loadMoreDataQueryTickets;
@synthesize feeds;
@synthesize customFeeds;

- (id)init
{
    self = [super init];
    if (self) {
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.openCell = nil;
        }] onViewState:tDidAppear do:^{
            [self.tableView scrollsToTop];
        }];
        
        self.reloadDataQueryTickets = [NSMutableDictionary dictionary];
        self.loadMoreDataQueryTickets = [NSMutableDictionary dictionary];
        self.feeds = [NSMutableDictionary dictionary];
        self.customFeeds = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height-44.0) style:UITableViewStylePlain];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    [self.tableView clearsContextBeforeDrawing];
    
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    self.tableViewSwipeView = [[UITableViewSwipeView alloc] initWithTableView:self.tableView delegate:self];
    self.tableViewAtBottomView = [[UITableViewAtBottomView alloc] initWithTableView:self.tableView delegate:self];
    
    [self.view addSubview:self.tableView];
    
    self.tableViewMaskView = [[UITableViewMaskView alloc] initWithRootView:self.tableView customMaskView:nil delegate:self];
    UIView *progressView = [[UIView alloc] init];
    [MBProgressHUD showHUDAddedTo:progressView animated:YES];
    [self.tableViewMaskView setCustomMaskView:progressView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pullToRefreshView = nil;
    self.tableViewSwipeView = nil;
    self.tableViewAtBottomView = nil;
}

// UITableView stuff

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tmpCurrentCustomFeed = [self currentCustomFeedForShowMode:self.showMode];
    if (tmpCurrentCustomFeed)
        return [tmpCurrentCustomFeed count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}

// "UITableViewAtBottomViewDelegate" Protocol

- (BOOL)tableViewCanBottom:(UITableView *)view
{
    if (self.isInFullscreenMode)
        return TRUE;
    else
        return FALSE;
}

- (void)tableViewDidBottom:(UITableView *)view
{
    [self loadMoreDataForShowMode:self.showMode withPrio:tHighest];
}

// "SSPullToRefreshViewDelegate" Protocol

- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view
{
    if (self.isInFullscreenMode)
        return TRUE;
    else
        return FALSE;
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self.pullToRefreshView startLoading];
    [self reloadDataForShowMode:self.showMode withPrio:tHighest];
}

// "UITableViewSwipeViewDelegate" Protocol

- (void)tableViewSwipeViewDidSwipeLeft:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTableCell *cell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    if (self.openCell) {
        if ([self.openCell row] == [indexPath row])
            return;
        
        APPTableCell *openCellCurrent = (APPTableCell*) [self.tableView cellForRowAtIndexPath:self.openCell];
        [openCellCurrent closeOnCompletion:^(BOOL isClosed) {
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
}

- (void)tableViewSwipeViewDidSwipeRight:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTableCell *cell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    [cell closeOnCompletion:^(BOOL isClosed) {
        if (isClosed) {
            self.openCell = nil;
        }
    } animated:YES];
}

// "HasTableView" Protocol

- (void)reloadDataForShowMode:(int)mode withPrio:(int)prio
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
            [self setQueryTicket:[self reloadDataConcreteForShowMode:mode withPrio:prio] forMode:mode forType:self.reloadDataQueryTickets];
            break;
        }
    }
}

- (APPQueryTicket*)reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    [NSException raise:NSInvalidArgumentException format:@"Method reloadData must be overwritten in subclass!"];
    return nil;
}

- (void)reloadDataResponse:(NSDictionary*)args
{
    int mode = [[args objectForKey:tContext] intValue];
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
                    [self.tableView reloadData];
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
                    [self.tableView reloadData];
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

- (void)loadMoreDataForShowMode:(int)mode withPrio:(int)prio
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
                [self setQueryTicket:[self loadMoreDataConcreteForShowMode:mode withPrio:prio] forMode:mode forType:self.loadMoreDataQueryTickets];
            break;
        }
    }
}

- (APPQueryTicket*)loadMoreDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    [NSException raise:NSInvalidArgumentException format:@"Method reloadData must be overwritten in subclass!"];
    return nil;
}

- (void)loadMoreDataResponse:(NSDictionary*)args
{
    int mode = [[args objectForKey:tContext] intValue];
    if (![args objectForKey:tError]) {
        
        // replace current feed for mode
        [self currentFeed:[args objectForKey:tFeed] forShowMode:mode];
        
        // finally, add feed entries to custom feed
        [[self currentCustomFeedForShowMode:mode] addObjectsFromArray:[[args objectForKey:tFeed] entries]];
        
        // if show mode of response is equal to current show mode,
        // update shown data
        if (mode == self.showMode)
        {
            [self.tableView reloadData];
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

- (void)toShowMode:(int)mode
{
    if (!mode || (self.showMode && self.showMode == mode))
        return;
    
    if ([self respondsToSelector:@selector(beforeShowModeChange)])
        [self beforeShowModeChange];
        
    self.showMode = mode;
        
    if ([self respondsToSelector:@selector(afterShowModeChange)])
        [self afterShowModeChange];
    
    switch ([self stateForShowMode:self.showMode forType:self.reloadDataQueryTickets])
    {
        // state of showmmode is loaded, just display it
        case tLoaded:
        {
            [self.tableViewMaskView unmaskOnCompletion:^(BOOL isUnmasked) {
                if (isUnmasked) {
                    [self.pullToRefreshView finishLoading];
                    [self.tableView reloadData];
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
                    [self reloadDataForShowMode:mode withPrio:tHighest];
                }
            }];
            break;
        }
    }
}

- (void)didFinishView:(NSNotification*)notification
{
    NSLog(@"Method didFinishView must be overwritten in subclass!");
}

- (void)addShowMode:(int)mode
{
    [self.reloadDataQueryTickets addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.loadMoreDataQueryTickets addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.feeds addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
    [self.customFeeds addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nil forKey:[NSNumber numberWithInt:mode]]];
}

- (void)resetAllShowModes
{
    NSArray* keys = [self.reloadDataQueryTickets allKeys];
    for(NSNumber* key in keys)
        [self resetShowMode:[key intValue]];
}

- (void)resetShowMode:(int)mode
{
    [self.reloadDataQueryTickets setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [self.loadMoreDataQueryTickets setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [self.feeds setObject:nil forKey:[NSNumber numberWithInt:mode]];
    [self.customFeeds setObject:nil forKey:[NSNumber numberWithInt:mode]];
}

- (GDataFeedBase*)currentFeedForShowMode:(int)mode;
{
    return [self currentFeed:nil forShowMode:mode];
}

- (GDataFeedBase*)currentFeed:(GDataFeedBase*)feed forShowMode:(int)mode;
{
    if (feed)
        [self.feeds setObject:feed forKey:[NSNumber numberWithInt:mode]];
    return (GDataFeedBase*)[self.feeds objectForKey:[NSNumber numberWithInt:mode]];
}

- (NSMutableArray*)currentCustomFeedForShowMode:(int)mode;
{
    return [self currentCustomFeed:nil forShowMode:mode];
}

- (NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed forShowMode:(int)mode;
{
    if (feed)
        [self.customFeeds setObject:feed forKey:[NSNumber numberWithInt:mode]];
    return (NSMutableArray*)[self.customFeeds objectForKey:[NSNumber numberWithInt:mode]];
}

- (int)stateForShowMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode && type && [type objectForKey:[NSNumber numberWithInt:mode]])
        return [(APPQueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]] state];
    else
        return -1;
}

- (int)prioForShowMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode && type && [type objectForKey:[NSNumber numberWithInt:mode]])
        return [(APPQueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]] prio];
    else
        return -1;
}

- (void)setPrio:(int)prio forShowMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (prio && mode && type && [type objectForKey:[NSNumber numberWithInt:mode]])
        [(APPQueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]] setPrio:prio];
}

- (APPQueryTicket*)queryTicketForMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (mode && type)
        return (APPQueryTicket*)[type objectForKey:[NSNumber numberWithInt:mode]];
}

- (void)setQueryTicket:(APPQueryTicket*)ticket forMode:(int)mode forType:(NSMutableDictionary*)type
{
    if (ticket && mode && type)
        [type setObject:ticket forKey:[NSNumber numberWithInt:mode]];
}

@end
