//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContent.h"
#import "APPProtocols.h"

#define tTodayStr @"today"
#define tWeekStr @"this_week"
#define tMonthStr @"this_month"
#define tAllStr @"all_time"

@implementation APPContent

+(NSString*)videoID:(GDataEntryYouTubeVideo*)video
{
    GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
    return [mediaGroupVideo videoID];
}

+(NSString*)timeString:(int)timeKey
{
    switch (timeKey)
    {
        case tToday:
        {
            return tTodayStr;
        }
        case tWeek:
        {
            return tWeekStr;
        }
        case tMonth:
        {
            return tMonthStr;
        }
        default:
        {
            return tAllStr;
        }
    }
}

+(int)likeStateOfVideo:(GDataEntryYouTubeVideo*)video
{
    if ([[[video rating] value] isEqualToString:@"like"])
        return tLikeLike;
    else if ([[[video rating] value] isEqualToString:@"dislike"])
        return tLikeDislike;
    else
        return tLike;
}

+(BOOL)isUser:(GDataEntryYouTubeUserProfile*)user authorOf:(GDataEntryBase*)entry;
{
    if (!user || !entry)
        return FALSE;

    NSEnumerator *e = [[entry authors] objectEnumerator];
    id object;
    while (object = [e nextObject]) {
        if ([[object name] isEqualToString:[(GDataPerson*)[[user authors] objectAtIndex:0] name]]) {
            return TRUE;
        }
    }
    return FALSE;
}

+(void)smallImageOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback
{
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    NSArray *thumbnails = [mediaGroup mediaThumbnails];
    [self loadImage:[NSURL URLWithString:[[thumbnails objectAtIndex:0] URLString]] callback:^(UIImage *image) {
        if (callback)
            callback(image);
        return;
    }];
}

+(void)largeImageOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback
{
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    NSArray *thumbnails = [mediaGroup mediaThumbnails];
    [self loadImage:[NSURL URLWithString:[[thumbnails objectAtIndex:3] URLString]] callback:^(UIImage *image) {
        if (callback)
            callback(image);
        return;
    }];
}

+(void)smallImageOfUser:(GDataEntryYouTubeUserProfile*)user callback:(void (^)(UIImage *image))callback
{
    GDataMediaThumbnail *thumb = [user thumbnail];
    [self loadImage:[NSURL URLWithString:[thumb URLString]] callback:^(UIImage *image) {
        if (callback)
            callback(image);
        return;
    }];
}

+(void)loadImage:(NSURL*)url callback:(void (^)(UIImage *image))callback
{
    if (url) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(image);
                    return;
                }
            });
        });
        dispatch_release(downloadQueue);
    }
}

@end