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

+(NSString*)timeString:(NSNumber*)key
{
    NSString *mode = NULL;
    if ([key isEqual:[NSNumber numberWithInt:tToday]])
        mode = tTodayStr;
    else if ([key isEqual:[NSNumber numberWithInt:tWeek]])
        mode = tWeekStr;
    else if ([key isEqual:[NSNumber numberWithInt:tMonth]])
        mode = tMonthStr;
    else
        mode = tAllStr;
    return mode;
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
    NSString *url;
    
    if ([video respondsToSelector:@selector(mediaGroup)]) {
        GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
        NSArray *thumbnails = [mediaGroup mediaThumbnails];
        if (!thumbnails || [thumbnails count] == 0) {
            if (callback)
                callback(nil);
            return;
        }
        
        url = [[thumbnails objectAtIndex:0] URLString];
    
    } else {
    
        GDataXMLElement *thumb = [video XMLElement];
        NSDictionary *myNS = [NSDictionary dictionaryWithObjectsAndKeys:@"http://search.yahoo.com/mrss/", @"m", nil];
        NSArray *elems = [thumb nodesForXPath:@"//entry/m:group/m:thumbnail" namespaces:myNS error:nil];
    
        if (!elems || [elems count] == 0) {
            if (callback)
                callback(nil);
            return;
        }
        
        url = [[[elems objectAtIndex:0] attributeForName:@"url"] stringValue];
    }
    
    if (!url) {
        if (callback)
            callback(nil);
        return;
    }
    
    [self loadImage:[NSURL URLWithString:url] callback:^(UIImage *image) {
        if (callback)
            callback(image);
        return;
    }];
}

+(void)largeImageOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback
{
    NSString *url;
    
    if ([video respondsToSelector:@selector(mediaGroup)]) {
        GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
        NSArray *thumbnails = [mediaGroup mediaThumbnails];
        if (!thumbnails || [thumbnails count] == 0) {
            if (callback)
                callback(nil);
            return;
        }
        
        url = [[thumbnails objectAtIndex:3] URLString];
        
    } else {
        
        GDataXMLElement *thumb = [video XMLElement];
        NSDictionary *myNS = [NSDictionary dictionaryWithObjectsAndKeys:@"http://search.yahoo.com/mrss/", @"m", nil];
        NSArray *elems = [thumb nodesForXPath:@"//entry/m:group/m:thumbnail" namespaces:myNS error:nil];
        
        if (!elems || [elems count] == 0) {
            if (callback)
                callback(nil);
            return;
        }
        
        url = [[[elems objectAtIndex:3] attributeForName:@"url"] stringValue];
    }
    
    if (!url) {
        if (callback)
            callback(nil);
        return;
    }
    
    [self loadImage:[NSURL URLWithString:url] callback:^(UIImage *image) {
        if (callback)
            callback(image);
        return;
    }];
}

+(void)smallImageOfUser:(GDataEntryYouTubeUserProfile*)user callback:(void (^)(UIImage *image))callback
{
    if (![user respondsToSelector:@selector(thumbnail)]) {
        if (callback)
            callback(nil);
        return;
    }
    
    GDataMediaThumbnail *thumb = [user thumbnail];
    [self loadImage:[NSURL URLWithString:[thumb URLString]] callback:^(UIImage *image) {
        if (callback)
            callback(image);
        return;
    }];
}

+(void)smallImageOfPlaylist:(GDataEntryYouTubePlaylistLink*)playlist callback:(void (^)(UIImage *image))callback
{
    GDataXMLElement *thumb = [playlist XMLElement];
    NSDictionary *myNS = [NSDictionary dictionaryWithObjectsAndKeys:@"http://search.yahoo.com/mrss/", @"m", nil];
    NSArray *elems = [thumb nodesForXPath:@"//entry/m:group/m:thumbnail" namespaces:myNS error:nil];
    
    if (!elems || [elems count] == 0) {
        if (callback)
            callback(nil);
        return;
    }
    
    [self loadImage:[NSURL URLWithString:[[[elems objectAtIndex:0] attributeForName:@"url"] stringValue]] callback:^(UIImage *image) {
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