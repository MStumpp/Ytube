//
//  APPVideo.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 02.09.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPVideo : NSObject
+(id)sharedInstance;
-(NSArray*)mostViewedVideos;
-(NSArray*)featuredVideos;
-(NSArray*)searchedVideos;
@end
