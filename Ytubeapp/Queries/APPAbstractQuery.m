//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPAbstractQuery.h"
#import "GTMOAuth2Authentication.h"
#import "APPGlobals.h"

@implementation APPAbstractQuery

-(GDataServiceGoogleYouTube*)service
{
    GDataServiceGoogleYouTube *ytService = (GDataServiceGoogleYouTube*)[APPGlobals getGlobalForKey:@"service"];
    if (ytService && [[ytService authorizer] canAuthorize])
            return ytService;
    return nil;
}

-(void)cancelled:(id)data
{
    if (self.ticket)
        [self.ticket cancelTicket];
}

-(void)addToDataWithValue:(NSString*)value andKey:(NSString*)key
{
    NSMutableDictionary *dict = (NSMutableDictionary*)[self data];
    [dict setValue:value forKey:key];
}

-(BOOL)hasError
{
    if ([(NSDictionary*)self.data objectForKey:@"error"])
        return true;
    return false;
}

@end