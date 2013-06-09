//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPAbstractQuery.h"

@interface APPFetchEntryWithURLQuery : APPAbstractQuery
-(void)fetchEntryWithURL:(NSURL*)entryURL;
@end