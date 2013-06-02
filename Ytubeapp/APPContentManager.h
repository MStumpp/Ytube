//
//  APPVideoManager.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 10.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import "GDataServiceGoogleYouTube.h"
#import "GTMOAuth2Authentication.h"
#import "GDataEntryContent.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "APPProtocols.h"
//#import "APPQueryTicket.h"
//#import "APPQuery.h"
#import "APPQueryManager.h"

static NSString *const kKeychainItemName = @"com.appmonster.Ytubeapp: YouTube";
static NSString *const kMyClientID = @"661861717112.apps.googleusercontent.com";
static NSString *const kMyClientSecret = @"Xprvp6Jba79Igbs3ciAEdn_y";
static NSString *const key = @"AI39si6H5KYXQGs3dqqYHYC7EGDDPhw8J8fbmDHua0Be83oR0hpN5mtBZWnIsxi78skPc6A-uWnvdAJGWmRlI-f1pqj27qol_w";

@protocol UserProfileChangeDelegate;

@interface APPContentManager : NSObject

+(APPContentManager*)classInstance;

-(void)initWithAuth:(GTMOAuth2Authentication*)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user))callback;
-(void)signIn:(GTMOAuth2Authentication *)auth onCompletion:(void (^)(GDataEntryYouTubeUserProfile *user))callback;
-(void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback;
-(GDataEntryYouTubeUserProfile*)getUserProfile;

//////
// Current User
//////

-(BOOL)isUserSignedIn;
-(void)currentUserProfileWithCallback:(void (^)(GDataEntryYouTubeUserProfile *user, NSError *error))callback;
-(void)imageForCurrentUserWithCallback:(void (^)(UIImage *image))callback;

-(void)registerUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer;
-(void)unregisterUserProfileObserverWithDelegate:(id<UserProfileChangeDelegate>) observer;

-(void)imageForUser:(GDataEntryYouTubeUserProfile*)user withCallback:(void (^)(UIImage *image))callback;

//////
// Videos
//////

-(APPQueryTicket*)recentlyFeaturedWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)mostPopular:(int)time prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)topRated:(int)time prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)topFavorites:(int)time prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)queryVideos:(NSString*)query prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)historyWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)relatedVideos:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;

//////
// Like / Dislike
//////

-(APPQueryTicket*)likeVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeVideo* video, NSError *error))callback;
-(APPQueryTicket*)dislikeVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeVideo* video, NSError *error))callback;
-(void)likeStateOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(NSInteger state))callback;

//////
// Comments
//////

-(APPQueryTicket*)comments:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeComment *comment, NSError *error))callback;
-(APPQueryTicket*)deleteComment:(GDataEntryYouTubeComment*)comment prio:(int)prio context:(id)context callback:(void (^)(BOOL deleted, NSError *error))callback;

//////
// My Videos
//////

-(APPQueryTicket*)myVideoWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)deleteMyVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL deleted, NSError *error))callback;

//////
// Playlists
//////

-(APPQueryTicket*)playlistsWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylistLink *playlist, NSError *error))callback;
-(APPQueryTicket*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(BOOL deleted, NSError *error))callback;

-(APPQueryTicket*)videosForPlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)addVideoToPlaylist:(GDataEntryYouTubeVideo*)video playlist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylist *entry, NSError *error))callback;
-(APPQueryTicket*)removeVideoFromPlaylist:(GDataEntryYouTubePlaylist*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL removed, NSError *error))callback;
-(APPQueryTicket*)queryPlaylists:(NSString*)query prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;

//////
// Watch Later
//////

-(APPQueryTicket*)videosForWatchLaterWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)videosForWatchLaterWithPrio:(int)prio context:(id)context callback:(void (^)(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error))callback;
-(APPQueryTicket*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylist *entry, NSError *error))callback;
-(APPQueryTicket*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL removed, NSError *error))callback;
-(APPQueryTicket*)isVideoWatchLater:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylist *video, NSError *error))callback;

//////
// Favorites
//////

-(APPQueryTicket*)favoritesWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;
-(APPQueryTicket*)favoritesWithPrio:(int)prio context:(id)context callback:(void (^)(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error))callback;
-(APPQueryTicket*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeFavorite *favorite, NSError *error))callback;
-(APPQueryTicket*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL removed, NSError *error))callback;
-(APPQueryTicket*)isVideoFavorite:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeFavorite *favorite, NSError *error))callback;

//////
// Channels
//////

/*-(void)channelsDelegate:(id)del didFinishSelector:(SEL)sel;
-(void)queryChannels:(NSString*)query delegate:(id)del didFinishSelector:(SEL)sel;*/

//////
// Images
//////

-(void)imageForVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback;
-(void)imageLargeForVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback;
-(void)imageLoader:(NSString*)url callback:(void (^)(UIImage *image))callback;
-(APPQueryTicket*)imageForPlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(UIImage *image))callback;
-(APPQueryTicket*)imageForComment:(GDataEntryYouTubeComment*)comment prio:(int)prio context:(id)context callback:(void (^)(UIImage *image))callback;

//////
// Load more data
//////

-(APPQueryTicket*)loadMoreData:(GDataFeedBase*)feed prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel;

//////
// Helpers
//////

-(BOOL)isUser:(GDataEntryYouTubeUserProfile*)user authorOf:(GDataEntryBase*)entry;

@end