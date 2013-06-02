//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPUserProfileQuery.h"

@interface APPUserProfileQuery()
@end

@implementation APPUserProfileQuery

-(void)load:(id)data
{
    NSURL *entryURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default"]];
    if ([self service]) {
        self.ticket = [[self service] fetchEntryWithURL:entryURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
            [self loadedWithData:entry andError:error];
        }];

    } else {
        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
    }
}

@end