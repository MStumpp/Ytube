//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistAdd.h"

@implementation APPPlaylistAdd

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubePlaylistLink *playlist = [dict objectForKey:@"playlist"];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/playlists?v=2"]];
    [self fetchEntryByInsertingEntry:playlist andURL:feedURL];
}

@end