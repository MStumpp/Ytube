//
//  APPVideoLogicHelper.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 16.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APPTableCell.h"
#import "GDataYouTube.h"

@interface APPVideoLogicHelper : NSObject

+ (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath delegate:(id<Base, HasTableView>)delegate;

+ (void)videoAction:(GDataEntryYouTubeVideo*)video button:(UIButton*)button delegate:(id<Base, HasTableView, VideoDependenceDelegate>)delegate;

+ (void)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist delegate:(id<Base, HasTableView, PlaylistDependenceDelegate>)delegate;

+ (void)removeVideoFromFavorites:favorite delegate:(id<Base, HasTableView>)delegate;

+ (void)deleteMyVideo:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate;

+ (void)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate;

+ (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath delegate:(id<Base, HasTableView>)delegate;

+ (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath delegate:(id<Base, HasTableView>)delegate;

@end
