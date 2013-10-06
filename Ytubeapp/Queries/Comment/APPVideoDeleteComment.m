//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoDeleteComment.h"

@implementation APPVideoDeleteComment

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*)props;
    GDataEntryYouTubeComment *comment = [dict objectForKey:@"comment"];
    [self deleteEntry:comment];
}

@end