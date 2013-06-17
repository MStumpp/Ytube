//
//  APPWatchLaterViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPWatchLaterViewController.h"
#import "APPVideoLogicHelper.h"

@interface APPWatchLaterViewController ()
@property (nonatomic, retain) GDataFeedBase *feedDefault;
@property (nonatomic, retain) NSMutableArray *customFeedDefault;
@end

@implementation APPWatchLaterViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_watch_later"];
        
        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.feedDefault = nil;
            self.customFeedDefault = nil;
        }] onViewState:tDidLoad do:^() {
            NSLog(@"WatchLater DIDLoad!!!!!!!!!!!!!!!");
            [this toShowMode:tDefault];
        }];
        
        [self toInitialState];
    }
    return self;
}

- (void)reloadData
{
    [self.contentManager videosForWatchLaterDelegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
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
    //NSUInteger row = [indexPath row];
    //UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // delete row locally
    //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
    
    [APPVideoLogicHelper removeVideoFromWatchLater:video delegate:self];
}

@end
