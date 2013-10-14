//
// Created by Matthias Stumpp on 02.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoRelatedVideos.h"

@implementation APPVideoRelatedVideos

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@/related", [APPContent videoID:video]]];
    NSLog(@"feedURL: %@", feedURL);
    [self fetchFeedWithURL:feedURL];
}

@end