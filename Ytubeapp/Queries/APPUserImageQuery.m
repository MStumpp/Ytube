//
// Created by Matthias Stumpp on 02.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "APPUserImageQuery.h"

@implementation APPUserImageQuery

-(void)load:(id)data
{
    GDataEntryYouTubeUserProfile *user = (GDataEntryYouTubeUserProfile*) data;
    if (user) {
        GDataMediaThumbnail *thumb = [user thumbnail];
        NSString *url = [thumb URLString];
        if (url) {
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadedWithData:image andError:nil];
                    return;
                });
            });
            dispatch_release(downloadQueue);
        }

        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"something went wrong"] code:1 userInfo:nil]]];

    } else {
        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"UserProfile is nil"] code:1 userInfo:nil]];
    }
}

@end