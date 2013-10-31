//
// Created by Matthias Stumpp on 02.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoQuery.h"

@implementation APPVideoQuery

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    NSString *query = [dict objectForKey:@"query"];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@", query]];
    [self fetchFeedWithURL:feedURL];
}

@end