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

@protocol State
@required
-(void)toInitialState;
@end

@protocol Base <UserProfileChangeDelegate, APPSliderViewControllerDelegate, State>
@end

@protocol HasTableView
@required
@property (nonatomic, strong) APPTableView *tableView;
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
@property (nonatomic, copy) APPSelectDelegateCallback callback;
@end

