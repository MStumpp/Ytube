//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoAddComment.h"


@implementation APPVideoAddComment

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeVideo *video = [dict objectForKey:@"video"];
    GDataEntryYouTubeComment *comment = [dict objectForKey:@"comment"];
    [self fetchEntryByInsertingEntry:comment andURL:[[[video comment] feedLink] URL]];
}

@end