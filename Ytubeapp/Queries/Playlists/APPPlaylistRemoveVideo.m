//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistRemoveVideo.h"

@implementation APPPlaylistRemoveVideo

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubePlaylist *playlistVideo = [dict objectForKey:@"playlistVideo"];
    [self deleteEntry:playlistVideo];
}

@end