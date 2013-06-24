//
// Created by Matthias Stumpp on 23.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPFetchMoreQuery.h"

@implementation APPFetchMoreQuery

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataFeedBase *feed = [dict objectForKey:@"feed"];
    [self fetchFeedWithURL:[[feed nextLink] URL]];
}

@end