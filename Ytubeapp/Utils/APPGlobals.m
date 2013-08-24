//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "APPGlobals.h"

@interface APPGlobals()
@property NSMutableDictionary *dict;
@end

@implementation APPGlobals

static APPGlobals *classInstance = nil;

+(APPGlobals*)classInstance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        classInstance.dict = [[NSMutableDictionary alloc] init];
    }
    return classInstance;
}

-(id)getGlobalForKey:(NSString*)key
{
    return [self.dict objectForKey:key];
}

-(void)setGlobalObject:(id)object forKey:(NSString*)key
{
    [self.dict setObject:object forKey:key];
}

@end