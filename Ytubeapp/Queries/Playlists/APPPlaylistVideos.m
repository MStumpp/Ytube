//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistVideos.h"

@implementation APPPlaylistVideos

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubePlaylistLink *playlist = [dict objectForKey:@"playlist"];
    NSLog(@"%@", [[playlist content] sourceURI]);
    [self fetchFeedWithURL:[NSURL URLWithString:[[playlist content] sourceURI]]];
}

@end