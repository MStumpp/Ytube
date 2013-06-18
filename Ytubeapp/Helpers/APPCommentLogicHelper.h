//
//  APPCommentLogicHelper.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 16.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPTableCell.h"
#import "GDataYouTube.h"

@interface APPCommentLogicHelper : NSObject
+(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath delegate:(id<Base, HasTableView>)delegate;
+(void)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate;
+(void)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate;
@end
