//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoIsFavorite.h"

@implementation APPVideoIsFavorite

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    
    NSString *videoID = [APPContent videoID:video];
    if (!videoID) {
        [self setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to retrieve video id for history item"] code:1 userInfo:nil]];
        [self loaded];
        return;
    }
    
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/favorites?v=2"]];
    id this = self;
    if ([self service]) {
        self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
            if (!error) {
                GDataEntryYouTubeFavorite *favorite;
                for (GDataEntryBase *entryBase in [feed entries]) {
                    favorite = (GDataEntryYouTubeFavorite*)entryBase;
                    GDataYouTubeMediaGroup *mediaGroupEntry = [favorite mediaGroup];
                    if ([videoID isEqualToString:[mediaGroupEntry videoID]]) {
                        // video is favorite
                        [this setResult:favorite];
                        [this loaded];
                        return;
                    }
                }
                // video is not favorite
                [this setResult:nil];
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

@end