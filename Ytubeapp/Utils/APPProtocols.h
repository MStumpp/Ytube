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

#define tToday 01
#define tWeek 02
#define tMonth 03
#define tAll 04
#define tDefault 05

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

@class GTMOAuth2Authentication;
@class UITableViewHeaderFormView;

@protocol SelectDelegate;

@interface APPProtocols
@end

@protocol UserProfileChangeDelegate
@optional
-(void)userSignedIn:(GDataEntryYouTubeUserProfile*)user andAuth:(GTMOAuth2Authentication*)auth;
-(void)userSignedOut;
@end

@protocol APPSliderViewControllerDelegate
@required
-(void)undoDefaultMode:(void (^)(void))callback;
-(void)doDefaultMode:(void (^)(void))callback;
@end

@protocol Base <UserProfileChangeDelegate, APPSliderViewControllerDelegate>
@end

@protocol VideoDependenceDelegate
@required
@property (nonatomic, retain) GDataEntryYouTubeVideo *video;
-(id)initWithVideo:(GDataEntryYouTubeVideo *)video;
@end

@protocol PlaylistDependenceDelegate
@required
@property (nonatomic, retain) GDataEntryYouTubePlaylistLink *playlist;
-(id)initWithPlaylist:(GDataEntryYouTubePlaylistLink *)playlist;
@end

typedef void(^APPSelectDelegateCallback)(GDataEntryBase *entryBase);
@protocol SelectDelegate
@required
@property (nonatomic, copy) APPSelectDelegateCallback afterSelect;
@end

