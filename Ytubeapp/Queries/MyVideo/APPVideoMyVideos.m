//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoMyVideos.h"

@implementation APPVideoMyVideos

-(void)load:(id)props
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/uploads"]];
    [self fetchFeedWithURL:feedURL];
}

@end