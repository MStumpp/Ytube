//
//  APPTextLogicHelper.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 17.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPTextLogicHelper.h"

@implementation APPTextLogicHelper

+(void)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist delegate:(id<Base, HasTableView, State>)delegate
{
    [delegate.contentManager deletePlaylist:playlist callback:^(BOOL deleted, NSError *error) {
        if (deleted && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deletedPlaylist" object:playlist];

        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to delete your playlist. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

@end
