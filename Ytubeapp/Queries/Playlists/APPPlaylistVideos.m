//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistVideos.h"


@implementation APPPlaylistVideos

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubePlaylistLink *playlist = [dict objectForKey:@"playlist"];
    [self fetchFeedWithURL:[NSURL URLWithString:[[playlist content] sourceURI]]];
}

@end