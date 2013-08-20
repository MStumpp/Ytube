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
    [self fetchFeedWithURL:feedURL];
}

@end