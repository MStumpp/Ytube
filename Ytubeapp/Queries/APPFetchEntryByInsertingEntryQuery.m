//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPFetchEntryByInsertingEntryQuery.h"

@implementation APPFetchEntryByInsertingEntryQuery

-(void)fetchEntryByInsertingEntry:(GDataEntryBase*)entry andURL:(NSURL*)url;
{
    if ([self service]) {
        id this = self;
        self.ticket = [[self service] fetchEntryByInsertingEntry:entry forFeedURL:url completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
            [this addToDataWithValue:entry andKey:@"entry"];
            [this addToDataWithValue:error andKey:@"error"];
            [this loaded];
        }];

    } else {
        [self addToDataWithValue:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil] andKey:@"error"];
        [self loaded];
    }
}

@end