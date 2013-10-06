//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPDefaultUserProfileQuery.h"

@implementation APPDefaultUserProfileQuery

-(void)load:(id)props
{
    NSURL *entryURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default"]];
    [self fetchEntryWithURL:entryURL];
}

@end