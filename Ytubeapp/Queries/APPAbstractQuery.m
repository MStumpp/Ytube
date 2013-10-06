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
    if (ytService) return ytService;
    return nil;
}

-(void)cancelled:(id)props
{
    if (self.ticket) [self.ticket cancelTicket];
}

-(BOOL)hasError
{
    if (self.error) return true;
    return false;
}

@end