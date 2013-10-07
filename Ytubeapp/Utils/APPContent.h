//
// Created by Matthias Stumpp on 03.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "GDataYouTube.h"

@interface APPContent : NSObject
+(NSString*)videoID:(GDataEntryYouTubeVideo *)video;
+(NSString*)timeString:(NSNumber*)mode;
+(int)likeStateOfVideo:(GDataEntryYouTubeVideo*)video;
+(BOOL)isUser:(GDataEntryYouTubeUserProfile*)user authorOf:(GDataEntryBase*)entry;
+(void)smallImageOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback;
+(void)largeImageOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback;
+(void)smallImageOfUser:(GDataEntryYouTubeUserProfile*)user callback:(void (^)(UIImage *image))callback;
+(void)loadImage:(NSURL*)url callback:(void (^)(UIImage *image))callback;
@end