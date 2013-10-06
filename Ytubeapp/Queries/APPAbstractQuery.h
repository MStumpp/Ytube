//
// Created by Matthias Stumpp on 01.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import "Query.h"
#import "APPContent.h"

@interface APPAbstractQuery : Query
@property GDataServiceTicket *ticket;
-(GDataServiceGoogleYouTube*)service;
-(BOOL)hasError;
@end