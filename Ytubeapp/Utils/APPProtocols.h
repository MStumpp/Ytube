//
//  APPProtocols.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 17.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import "SSPullToRefreshView.h"
#import "UITableViewSwipeView.h"
#import "UITableViewAtBottomView.h"
#import "UITableViewMaskView.h"
#import "SmartNavigationController.h"
#import "APPTableCell.h"

// button tags

#define tToday 1
#define tWeek 2
#define tMonth 3
#define tAll 4
#define tDefault 5
#define tBack 21
#define tEdit 22
#define tAdd 23
#define tLike 24
#define tLikeLike 25
#define tLikeDislike 26
#define tAddToPlaylist 27
#define tWatchLater 28
#define tFavorites 29
#define tComments 30

typedef void(^APPSelectDelegateCallback)(GDataEntryBase *entryBase);

@interface APPProtocols
@end

@protocol APPSliderViewControllerDelegate
@required
-(void)undoDefaultMode:(void (^)(void))callback;
-(void)doDefaultMode:(void (^)(void))callback;
@end

@protocol VideoDependenceDelegate
@required
@property (nonatomic) GDataEntryYouTubeVideo *video;
-(id)initWithVideo:(GDataEntryYouTubeVideo*)video;
@end

@protocol PlaylistDependenceDelegate
@required
@property (nonatomic) GDataEntryYouTubePlaylistLink *playlist;
-(id)initWithPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;
@end

@protocol SelectDelegate
@required
@property (nonatomic, strong) APPSelectDelegateCallback afterSelect;
@end

