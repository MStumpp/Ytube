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
#import "APPTableView.h";

// showMode

#define tToday 1
#define tWeek 2
#define tMonth 3
#define tAll 4
#define tDefault 5

// Content

//#define tVideos 11
//#define tChannels 12
//#define tPlaylists 13

// Buttons

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

//#define tComments 01
#define tRelatedVideos 02

#define tIn 01
#define tOut 02
#define tInOut 03

@class GTMOAuth2Authentication;
@class UITableViewHeaderFormView;

@protocol SelectDelegate;
@class GDataEntryYouTubeVideo;
@class GDataEntryYouTubePlaylistLink;
@class GDataEntryBase;

@interface APPProtocols
@end

@protocol APPSliderViewControllerDelegate
@required
-(void)undoDefaultMode:(void (^)(void))callback;
-(void)doDefaultMode:(void (^)(void))callback;
@end

@protocol Base <APPSliderViewControllerDelegate>
@end

@protocol VideoDependenceDelegate
@required
@property (nonatomic, retain) GDataEntryYouTubeVideo *video;
-(id)initWithVideo:(GDataEntryYouTubeVideo*)video;
@end

@protocol PlaylistDependenceDelegate
@required
@property (nonatomic, retain) GDataEntryYouTubePlaylistLink *playlist;
-(id)initWithPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;
@end

typedef void(^APPSelectDelegateCallback)(GDataEntryBase *entryBase);
@protocol SelectDelegate
@required
@property (nonatomic, copy) APPSelectDelegateCallback afterSelect;
@end

