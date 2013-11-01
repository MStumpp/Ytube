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

#define tNone 10
#define tToday 11
#define tWeek 12
#define tMonth 13
#define tAll 14
#define tDefault 15
#define tBack 16
#define tEdit 17
#define tAdd 18
#define tLike 19
#define tLikeLike 20
#define tLikeDislike 21
#define tAddToPlaylist 22
#define tSignOut 23

#define tSearch 51
#define tMostPopular 52
#define ttopRated 53
#define ttopFavorites 54
#define tRecentlyFeatured 55
#define tFavorites 56
#define tPlaylists 57
#define tHistory 58
#define tWatchLater 59
#define tMyVideos 60
#define tComments 61

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

