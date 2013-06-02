//
// Created by Matthias Stumpp on 02.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoRecentlyFeatured.h"


@implementation APPVideoRecentlyFeatured

-(void)load:(id)data
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/recently_featured"]];
    if ([self service]) {
        self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
            [self loadedWithData:entry andError:error];
        }];

    } else {
        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
    }
}

@end