//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoIsWatchLater.h"

@implementation APPVideoIsWatchLater

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2"]];
    id this = self;
    if ([self service]) {
        self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
            if (!error) {
                GDataEntryYouTubePlaylist *playlist;
                for (GDataEntryBase *entryBase in [feed entries]) {
                    playlist = (GDataEntryYouTubePlaylist*)entryBase;
                    GDataYouTubeMediaGroup *mediaGroupEntry = [playlist mediaGroup];
                    if ([[mediaGroupVideo videoID] isEqualToString:[mediaGroupEntry videoID]]) {
                        [this addToDataWithValue:playlist andKey:@"playlist"];
                        [this loaded];
                        return;
                    }
                }
                [this loaded];

            } else {
                [this addToDataWithValue:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to fetch watch later videos"] code:1 userInfo:nil] andKey:@"error"];
                [this loaded];

            }
        }];
    } else {
        [this addToDataWithValue:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil] andKey:@"error"];
        [this loaded];

    }
}

@end