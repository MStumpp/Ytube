//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentFavoritesController.h"

@implementation APPContentFavoritesController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_favorites"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromFavorites object:nil];
    }
    return self;
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper favoriteVideosOnShowMode:mode withPrio:p delegate:tableView];
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
    GDataEntryYouTubeFavorite *favorite = (GDataEntryYouTubeFavorite*) [[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPQueryHelper removeVideoFromFavorites:favorite];
}

-(void)processEvent:(NSNotification*)notification
{
    if (![(NSDictionary*)[notification object] objectForKey:@"error"])
        [self.tableView clearViewAndReloadAll];
}

@end