//
//  APPTextLogicHelper.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 17.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPTextCell.h"
#import "GDataYouTube.h"

@interface APPTextLogicHelper : NSObject

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath delegate:(id<Base, HasTableView>)delegate;

+ (void)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist delegate:(id<Base, HasTableView>)delegate;
    
@end
