//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoRemoveFromFavorites.h"

@implementation APPVideoRemoveFromFavorites

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];

    if ([video isMemberOfClass:[GDataEntryYouTubeFavorite class]]) {
        if ([self service]) {
            self.ticket = [[self service] deleteEntry:video completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
                [self loadedWithData:entry andError:error];
            }];

        } else {
            [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
        }

    } else {
        GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
        NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/favorites?v=2"]];
        if ([self service]) {
            self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
                if (!error) {
                    GDataEntryYouTubeFavorite *favorite;
                    for (GDataEntryBase *entryBase in [feed entries]) {
                        favorite = (GDataEntryYouTubeFavorite*)entryBase;
                        GDataYouTubeMediaGroup *mediaGroupEntry = [favorite mediaGroup];
                        if ([[mediaGroupVideo videoID] isEqualToString:[mediaGroupEntry videoID]]) {
                            if ([self service]) {
                                self.ticket = [[self service] deleteEntry:favorite completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
                                    [self loadedWithData:entry andError:error];
                                }];
                            } else {
                                [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
                            }
                            return;
                        }
                    }
                    [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"provided video is not a favorite video"] code:1 userInfo:nil]];
                } else {
                    [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to fetch favorites"] code:1 userInfo:nil]];
                }
            }];
        } else {
            [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
        }
    }
}

@end