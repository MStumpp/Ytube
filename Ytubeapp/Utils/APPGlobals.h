//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface APPGlobals : NSObject
+(APPGlobals*)classInstance;
-(id)getGlobalForKey:(NSString*)key;
-(void)setGlobalObject:(id)object forKey:(NSString*)key;
@end