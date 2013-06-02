//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "GDataServiceGoogleYouTube.h"
#import "GDataYouTube.h"
#import "Query.h"

@interface APPAbstractQuery : Query
@property (strong, nonatomic) GDataServiceTicket *ticket;
-(GDataServiceGoogleYouTube*)service;
// some helpers methods
-(NSString*)videoID:(GDataEntryYouTubeVideo *)video;
-(NSString*)timeString:(int)timeKey;
@end