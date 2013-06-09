//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPFetchEntryWithURLQuery.h"

@implementation APPFetchEntryWithURLQuery

-(void)fetchEntryWithURL:(NSURL*)entryURL
{
    if ([self service]) {
        self.ticket = [[self service] fetchEntryWithURL:entryURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
            [self loadedWithData:entry andError:error];
        }];

    } else {
        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
    }
}

@end