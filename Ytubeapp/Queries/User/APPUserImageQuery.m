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
    id this = self;
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeUserProfile *user = [dict objectForKey:@"user"];
    if (user) {
        GDataMediaThumbnail *thumb = [user thumbnail];
        NSString *url = [thumb URLString];
        if (url) {
            NSLog(@"APPUserImageQuery 1");
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *image = [[UIImage alloc] initWithData:data];
            //dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            //dispatch_async(downloadQueue, ^{
                //NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                //UIImage *image = [UIImage imageWithData:data];
                //dispatch_async(dispatch_get_main_queue(), ^{
            if (image)
                NSLog(@"APPUserImageQuery 2");

            [this addToDataWithValue:image andKey:@"image"];
            [this loaded];
                //});
            //});
            //dispatch_release(downloadQueue);
            return;
        }

        [this addToDataWithValue:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"something went wrong"] code:1 userInfo:nil] andKey:@"error"];
        [this loaded];

    } else {
        [this addToDataWithValue:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"UserProfile is nil"] code:1 userInfo:nil] andKey:@"error"];
        [this loaded];
    }
}

@end