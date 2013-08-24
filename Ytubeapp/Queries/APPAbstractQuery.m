//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPAbstractQuery.h"
#import "APPGlobals.h"

@implementation APPAbstractQuery

-(GDataServiceGoogleYouTube*)service
{
    GDataServiceGoogleYouTube *ytService = (GDataServiceGoogleYouTube*)[[APPGlobals classInstance] getGlobalForKey:@"service"];
    if (ytService)
        return ytService;
    return nil;
}

-(void)cancelled:(id)data
{
    if (self.ticket)
        [self.ticket cancelTicket];
}

-(void)addToDataWithValue:(id)object andKey:(NSString*)key
{
    if (!object)
        return;
    NSMutableDictionary *dict = (NSMutableDictionary*)self.data;
    [dict setObject:object forKey:key];
}

-(BOOL)hasError
{
    if ([(NSDictionary*)self.data objectForKey:@"error"])
        return true;
    return false;
}

@end