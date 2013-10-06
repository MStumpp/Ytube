//
// Created by Matthias Stumpp on 02.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoTopRated.h"

@implementation APPVideoTopRated

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    NSString *mode = [dict objectForKey:@"mode"];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_rated?time=%@", [APPContent timeString:mode]]];
    [self fetchFeedWithURL:feedURL];
}

@end