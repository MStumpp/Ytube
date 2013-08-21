//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentWatchLaterController.h"

@implementation APPContentWatchLaterController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_watch_later"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromWatchLater object:nil];

        [[self configureDefaultState] onViewState:tDidLoadViewState do:^{
            // reloads table view content
            [self.tableView clearViewAndReloadAll];
            [self.tableView toDefaultShowMode];
        }];
        [self toDefaultStateForce];
    }
    return self;
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper watchLaterVideosOnShowMode:mode withPrio:p delegate:tableView];
}

-(Query*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)p
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:p delegate:tableView];
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView*)tableView forMode:(int)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo*) [[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPQueryHelper removeVideoFromWatchLater:video];
}

-(void)processEvent:(NSNotification*)notification
{
    if (![(NSDictionary*)[notification object] objectForKey:@"error"])
        [self.tableView clearViewAndReloadAll];
}

@end