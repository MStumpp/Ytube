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
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeUserProfile *user = [dict objectForKey:@"user"];
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

NSURL *feedURL = [NSURL URLWithString:[[[comment authors] objectAtIndex:0] URI]];
return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
    if (error == nil) {
        GDataEntryYouTubeUserProfile *profile = (GDataEntryYouTubeUserProfile*)object;
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[profile thumbnail] URLString]]];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback)
                    callback(image);
            });
        });
        dispatch_release(downloadQueue);

    } else {
        if (callback)
            callback(nil);
    }
}] fetchFeedWithURL:feedURL] prio:prio];

@end