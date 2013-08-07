//
// Created by Matthias Stumpp on 23.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPTableCell.h"
#import "GDataYouTube.h"
#import "APPGlobals.h"

#define eventVideoWatched @"videoWatched"

@interface APPQueryHelper : NSObject

// video

#define eventRelatedVideosLoaded @"relatedVideosLoaded"
+(QueryTicket*)relatedVideos:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventTopFavoriteVideosLoaded @"topFavoriteVideosLoaded"
+(QueryTicket*)topFavoriteVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventTopRatedVideosLoaded @"topRatedVideosLoaded"
+(QueryTicket*)topRatedVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventFeaturedVideosLoaded @"featuredVideosLoaded"
+(QueryTicket*)featuredVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventMostViewedVideosLoaded @"mostViewedVideosLoaded"
+(QueryTicket*)mostViewedVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventSearchVideosLoaded @"searchVideosLoaded"
+(QueryTicket*)searchVideos:(NSString*)query showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventPlaylistVideosLoaded @"playlistVideosLoaded"
+(QueryTicket*)playlistVideos:(GDataEntryYouTubePlaylistLink*)playlist showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventWatchLaterVideosLoaded @"watchLaterVideosLoaded"
+(QueryTicket*)watchLaterVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventFavoriteVideosLoaded @"favoriteVideosLoaded"
+(QueryTicket*)favoriteVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventHistoryVideosLoaded @"historyVideosLoaded"
+(QueryTicket*)historyVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventMyVideosLoaded @"myVideosLoaded"
+(QueryTicket*)myVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventVideoLiked @"videoLiked"
+(QueryTicket*)likeVideo:(GDataEntryYouTubeVideo*)video;

#define eventVideoUnliked @"videoUnliked"
+(QueryTicket*)unlikeVideo:(GDataEntryYouTubeVideo*)video;

#define eventAddedVideoToPlaylist @"addedVideoToPlaylist"
+(QueryTicket*)addVideo:(GDataEntryYouTubeVideo*)video toPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventRemovedVideoFromPlaylist @"removedVideoFromPlaylist"
+(QueryTicket*)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventAddedVideoToFavorites @"addedVideoToFavorites"
+(QueryTicket*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video;

#define eventRemovedVideoFromFavorites @"removedVideoFromFavorites"
+(QueryTicket*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video;

#define eventAddedVideoToWatchLater @"addedVideoToWatchLater"
+(QueryTicket*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video;

#define eventRemovedVideoFromWatchLater @"removedVideoFromWatchLater"
+(QueryTicket*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video;

#define eventDeletedMyVideo @"deletedMyVideo"
+(QueryTicket*)deleteMyVideo:(GDataEntryYouTubeVideo*)video;

// playlist

+(QueryTicket*)playlistsOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventAddedPlaylist @"addedPlaylist"
+(QueryTicket*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventDeletedPlaylist @"deletedPlaylist"
+(QueryTicket*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

// comment

+(QueryTicket*)videoComments:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventAddedCommentToVideo @"addedCommentToVideo"
+(QueryTicket*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video;

#define eventDeletedCommentFromVideo @"deletedCommentFromVideo"
+(QueryTicket*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video;

// fetch more

+(QueryTicket*)fetchMore:(GDataFeedBase*)feed showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

@end