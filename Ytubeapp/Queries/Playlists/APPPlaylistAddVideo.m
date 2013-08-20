//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistAddVideo.h"

@implementation APPPlaylistAddVideo

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    GDataEntryYouTubePlaylistLink *playlist = [dict objectForKey:@"playlist"];
    [self fetchEntryByInsertingEntry:video andURL:[[playlist editLink] URL]];
}

@end