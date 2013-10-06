//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoRemoveFromWatchLater.h"

@implementation APPVideoRemoveFromWatchLater

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];

    id this = self;
    if ([video isMemberOfClass:[GDataEntryYouTubePlaylist class]]) {
        if ([self service]) {
            self.ticket = [[self service] deleteEntry:video completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
                [this setResult:entry];
                [this setError:error];
                [this loaded];
            }];

        } else {
            [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
            [this loaded];
        }

    } else {
        GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
        NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2"]];
        if ([self service]) {
            self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
                if (!error) {
                    GDataEntryYouTubePlaylist *playlist;
                    for (GDataEntryBase *entryBase in [feed entries]) {
                        playlist = (GDataEntryYouTubePlaylist*)entryBase;
                        GDataYouTubeMediaGroup *mediaGroupEntry = [playlist mediaGroup];
                        if ([[mediaGroupVideo videoID] isEqualToString:[mediaGroupEntry videoID]]) {
                            if ([self service]) {
                                self.ticket = [[self service] deleteEntry:playlist completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
                                    [this setResult:entry];
                                    [this setError:error];
                                    [this loaded];
                                }];
                            } else {
                                [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
                                [this loaded];
                            }
                            return;
                        }
                    }
                    [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"provided video is not a watch later video"] code:1 userInfo:nil]];
                    [this loaded];

                } else {
                    [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to fetch favorites"] code:1 userInfo:nil]];
                    [this loaded];
                }
            }];
        } else {
            [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
            [this loaded];
        }
    }
}

@end