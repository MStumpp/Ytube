//
//  DataCache.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 05.10.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCache : NSObject

+(DataCache*)instance;
-(id)reload:(NSString*)key;
-(id)loadMore:(NSString*)key;

@end
