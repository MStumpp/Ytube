//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentPlaylistVideosController.h"
#import "APPPlaylistVideos.h"
#import "APPFetchMoreQuery.h"

#define tPlaylistVideosAll @"playlist_videos_all"

@implementation APPContentPlaylistVideosController
@synthesize playlist;

-(id)initWithPlaylist:(GDataEntryYouTubePlaylistLink*)pl
{
    self = [self init];
    if (self) {
        self.playlist = pl;
        [self.dataCache clearData:tPlaylistVideosAll];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_playlists"];
        
        [self.dataCache configureReloadDataForKey:tPlaylistVideosAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPPlaylistVideos instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.playlist, @"playlist", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [self.dataCache configureLoadMoreDataForKey:tPlaylistVideosAll withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
            queryHandler(key, [[APPFetchMoreQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSDictionary dictionaryWithObjectsAndKeys:previous, @"feed", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToPlaylist object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromPlaylist object:nil];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    [self.tableView addDefaultShowMode:tPlaylistVideosAll];
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubePlaylist *pl = (GDataEntryYouTubePlaylist*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.dataCache getData:mode] removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [APPQueryHelper removeVideo:pl fromPlaylist:self.playlist];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    NSDictionary *context = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if ([context objectForKey:@"playlist"] == self.playlist)
        if (![(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self.tableView clearViewAndReloadAll];
}

@end