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

        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tDefault];
        }];

        [self toInitialState];
    }
    return self;
}

-(QueryTicket*)reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    return [self.contentManager mostPopular:mode prio:prio context:[NSNumber numberWithInt:mode] delegate:self didFinishSelector:@selector(reloadDataResponse:)];
}

-(QueryTicket*)loadMoreDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    if ([self currentFeedForShowMode:mode])
        return [self.contentManager loadMoreData:[self currentFeedForShowMode:mode] prio:prio context:[NSNumber numberWithInt:mode] delegate:self didFinishSelector:@selector(loadMoreDataResponse:)];
    return nil;
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle didSelectEntry:(GDataEntryBase*)entry
{
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *)entry;
    [APPVideoLogicHelper removeVideoFromWatchLater:video delegate:self];
}

@end