//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistRemoveVideo.h"

@implementation APPPlaylistRemoveVideo

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubePlaylist *video = [dict objectForKey:@"video"];
    [self deleteEntry:video];
}

@end