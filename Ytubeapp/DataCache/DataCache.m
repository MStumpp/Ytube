//
//  DataCache.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 05.10.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

static DataCache *classInstance = nil;

+(DataCache*)instance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:nil] init];
    }
    return classInstance;
}

@end
