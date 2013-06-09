//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistImageOfPlaylist.h"

@implementation APPPlaylistImageOfPlaylist

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubePlaylistLink *playlist = [dict objectForKey:@"playlist"];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[playlist content] sourceURI], @"&max-results=1"]];

    if ([self service]) {
        self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
            if (!error) {
                GDataEntryBase *entry = [[feed entries] objectAtIndex:0];
                GDataEntryYouTubeVideo *ytvideo = (GDataEntryYouTubeVideo *) entry;
                GDataYouTubeMediaGroup *mediaGroup = [ytvideo mediaGroup];
                NSArray *thumbnails = [mediaGroup mediaThumbnails];
                [APPContent loadImage:[NSURL URLWithString:[[thumbnails objectAtIndex:0] URLString]] callback:^(UIImage *image){
                    if (image) {
                        [self loadedWithData:image andError:nil];
                    } else {
                        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to load image from url"] code:1 userInfo:nil]];
                    }
                }];
            } else {
                [self loadedWithData:nil andError:error];
            }
        }];

    } else {
        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
    }
}

@end