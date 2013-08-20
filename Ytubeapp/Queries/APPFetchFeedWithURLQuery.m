//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPFetchFeedWithURLQuery.h"

@implementation APPFetchFeedWithURLQuery

-(void)fetchFeedWithURL:(NSURL*)feedURL
{
    id this = self;
    if ([self service]) {
        self.ticket = [[self service] fetchFeedWithURL:feedURL completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
            [this addToDataWithValue:feed andKey:@"feed"];
            [this addToDataWithValue:error andKey:@"error"];
            [this loaded];
        }];

    } else {
        [this addToDataWithValue:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil] andKey:@"error"];
        [this loaded];
    }
}

@end