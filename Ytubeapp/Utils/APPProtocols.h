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
#import "TVNavigationController.h"

// Time scopes

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

//#define tBack 21
#define tEdit 22
#define tAdd 23
#define tLike 24
#define tLikeLike 25
#define tLikeDislike 26
#define tAddToPlaylist 27
#define tWatchLater 28
#define tFavorites 29
#define tComments 30

// States
#define tInitialState 01

// Show modes

//#define tComments 01
#define tRelatedVideos 02

@class APPContentManager;
@class GTMOAuth2Authentication;

@interface APPProtocols : NSObject
@end

@protocol UserProfileChangeDelegate
@required
@property (nonatomic, strong) GDataEntryYouTubeUserProfile *userProfile;
-(void)userSignedIn:(GDataEntryYouTubeUserProfile*)user andAuth:(GTMOAuth2Authentication*)auth;
-(void)userSignedOut;
@end

@protocol APPSliderViewConrollerDelegate <TVNavigationControllerDelegate>
@required
@property BOOL isInFullscreenMode;
-(void)didFullScreenModeInitially:(void (^)(void))callback;
-(void)willSplitScreenMode:(void (^)(void))callback;
-(void)didFullScreenModeAfterSplitScreen:(void (^)(void))callback;
@end

@protocol State
@required
-(void)toInitialState;
@end

@protocol Base <UserProfileChangeDelegate, APPSliderViewConrollerDelegate, State>
@required
@property (nonatomic, strong) APPContentManager *contentManager;
-(TVNavigationController*)getNavigationController;
@end

@protocol HasTableView <UITableViewDataSource, UITableViewDelegate, SSPullToRefreshViewDelegate, UITableViewSwipeViewDelegate, UITableViewAtBottomViewDelegate, UITableViewMaskViewDelegate>
@required
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) UITableViewSwipeView *tableViewSwipeView;
@property (nonatomic, strong) UITableViewAtBottomView *tableViewAtBottomView;
@property (nonatomic, strong) UITableViewMaskView *tableViewMaskView;
@property (nonatomic, strong) NSIndexPath *openCell;
@property int showMode;
@property (strong, nonatomic) NSMutableDictionary *reloadDataQueryTickets;
@property (strong, nonatomic) NSMutableDictionary *loadMoreDataQueryTickets;
@property (strong, nonatomic) NSMutableDictionary *feeds;
@property (strong, nonatomic) NSMutableDictionary *customFeeds;
-(void)addShowMode:(int)mode;
-(void)toShowMode:(int)mode;
-(GDataFeedBase*)currentFeedForShowMode:(int)mode;
-(GDataFeedBase*)currentFeed:(GDataFeedBase*)feed forShowMode:(int)mode;
-(NSMutableArray*)currentCustomFeedForShowMode:(int)mode;
-(NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed forShowMode:(int)mode;
-(void)reloadDataForShowMode:(int)mode withPrio:(int)prio;
-(APPQueryTicket*)reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio;
-(void)reloadDataResponse:(NSDictionary*)args;
-(void)loadMoreDataForShowMode:(int)mode withPrio:(int)prio;
-(APPQueryTicket*)loadMoreDataConcreteForShowMode:(int)mode withPrio:(int)prio;
-(void)loadMoreDataResponse:(NSDictionary*)args;
@optional
-(void)beforeShowModeChange;
-(void)afterShowModeChange;
@end

@protocol VideoDependenceDelegate
@required
@property (nonatomic, retain) GDataEntryYouTubeVideo *video;
- (id)initWithVideo:(GDataEntryYouTubeVideo *)video;
@end

@protocol PlaylistDependenceDelegate
@required
@property (nonatomic, retain) GDataEntryYouTubePlaylistLink *playlist;
- (id)initWithPlaylist:(GDataEntryYouTubePlaylistLink *)playlist;
@end