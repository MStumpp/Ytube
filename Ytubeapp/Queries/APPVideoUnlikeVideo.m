//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoUnlikeVideo.h"


@implementation APPVideoUnlikeVideo

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    [[video rating] setValue:@"unlike"];
    [self fetchEntryByInsertingEntry:video andURL:[[video ratingsLink] URL]];
}

@end