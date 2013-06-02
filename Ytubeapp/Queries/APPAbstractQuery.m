//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPAbstractQuery.h"
#import "GDataServiceGoogleYouTube.h"

#define tTodayStr @"today"
#define tWeekStr @"this_week"
#define tMonthStr @"this_month"
#define tAllStr @"all_time"

@implementation APPAbstractQuery

-(GDataServiceGoogleYouTube*)service
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults)
        return [standardUserDefaults objectForKey:@"service"];
    return nil;
}

-(void)pause:(id)data

{
    if (self.ticket)
        [self.ticket cancelTicket];
    [self pausedWithData:nil andError:nil];
}

-(void)cancel:(id)data

{
    if (self.ticket)
        [self.ticket cancelTicket];
    [self cancelledWithData:nil andError:nil];
}

-(NSString*)videoID:(GDataEntryYouTubeVideo *)video
{
    GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
    return [mediaGroupVideo videoID];
}

-(NSString*)timeString:(int)timeKey
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

@end