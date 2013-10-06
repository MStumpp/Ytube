//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistQuery.h"

@implementation APPPlaylistQuery

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    NSString *query = [dict objectForKey:@"query"];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/snippets?q=%@", query]];
    [self fetchFeedWithURL:feedURL];
}

@end