//
// Created by Matthias Stumpp on 02.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoTopRated.h"


@implementation APPVideoTopRated

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    int time = [[dict objectForKey:@"time"] intValue];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_rated?time=%@", [self timeString:time]]];
    [self fetchFeedWithURL:feedURL];
}

@end