//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistAddVideo.h"

@implementation APPPlaylistAddVideo

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    GDataEntryYouTubePlaylistLink *playlist = [dict objectForKey:@"playlist"];
    NSString *url = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/%@?v=2", [playlist playlistID]];
    [self fetchEntryByInsertingEntry:video andURL:[NSURL URLWithString:url]];
}

@end