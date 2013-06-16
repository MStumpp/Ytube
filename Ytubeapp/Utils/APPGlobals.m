//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "APPGlobals.h"

@implementation APPGlobals

+(id)getGlobalForKey:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        return [standardUserDefaults objectForKey:key];
    }
    return nil;
}

+(void)setGlobalObject:(id)object forKey:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:object forKey:key];
        [standardUserDefaults synchronize];
    }
}

@end