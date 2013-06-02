//
//  APPPlaylistsDetailsViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPPlaylistsDetailsViewController.h"
#import "APPVideoDetailViewController.h"
#import "APPVideoLogicHelper.h"

@interface APPPlaylistsDetailsViewController()
@property (nonatomic, retain) GDataFeedBase *feedDefault;
@property (nonatomic, retain) NSMutableArray *customFeedDefault;
@end

@implementation APPPlaylistsDetailsViewController

@synthesize playlist;

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_playlists"];
        
        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.feedDefault = nil;
            self.customFeedDefault = nil;
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tDefault];
        }];
        
        [self toInitialState];
    }
    return self;
}

- (id)initWithPlaylist:(GDataEntryYouTubePlaylistLink *)pl
{
    self = [self init];
    if (self) {
        self.playlist = pl;
    }
    return self;
}

- (void)reloadData
{
    if (self.playlist)
        [self.contentManager videosForPlaylist:self.playlist delegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
}

- (void)loadMoreData
{
    if ([self currentFeed])
        [self.contentManager loadMoreData:[self currentFeed] delegate:self didFinishSelector:@selector(loadMoreDataResponse:finishedWithFeed:error:)];
}

- (GDataFeedBase*)currentFeed:(GDataFeedBase*)feed
{
    switch (self.showMode)
    {
        case tDefault:
            if (feed)
                self.feedDefault = feed;
            return self.feedDefault;
        default:
            return nil;
    }
}

- (NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed;
{
    switch (self.showMode)
    {
        case tDefault:
            if (feed)
                self.customFeedDefault = feed;
            return self.customFeedDefault;
        default:
            return nil;
    }
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    GDataEntryYouTubePlaylist *pl = (GDataEntryYouTubePlaylist*) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
    [APPVideoLogicHelper removeVideo:pl fromPlaylist:self.playlist delegate:self];
}

@end
