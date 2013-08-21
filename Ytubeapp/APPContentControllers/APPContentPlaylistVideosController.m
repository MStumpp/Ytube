//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentPlaylistVideosController.h"

@implementation APPContentPlaylistVideosController
@synthesize playlist;

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_playlists"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToPlaylist object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromPlaylist object:nil];

        [self toDefaultStateForce];
    }
    return self;
}

-(id)initWithPlaylist:(GDataEntryYouTubePlaylistLink*)pl
{
    self = [self init];
    if (self) {
        self.playlist = pl;
    }
    return self;
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper playlistVideos:self.playlist showMode:mode withPrio:p delegate:tableView];
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
    GDataEntryYouTubePlaylist *pl = (GDataEntryYouTubePlaylist*)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPQueryHelper removeVideo:pl fromPlaylist:self.playlist];
}

-(void)processEvent:(NSNotification*)notification
{
    if ([[(NSDictionary*)[notification object] objectForKey:@"playlist"] isEqual:self.playlist])
        if (![(NSDictionary*)[notification object] objectForKey:@"error"])
            [self.tableView clearViewAndReloadAll];
}

@end