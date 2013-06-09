//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoLikeVideo.h"


@implementation APPVideoLikeVideo

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    [[video rating] setValue:@"like"];
    [self fetchEntryByInsertingEntry:video andURL:[[video ratingsLink] URL]];
}

@end