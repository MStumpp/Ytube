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
#import "Query.h"

@interface APPQueryHelper : NSObject

// video showing (APPTableView)

#define eventRelatedVideosLoaded @"relatedVideosLoaded"
+(Query*)relatedVideos:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventTopFavoriteVideosLoaded @"topFavoriteVideosLoaded"
+(Query*)topFavoriteVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventTopRatedVideosLoaded @"topRatedVideosLoaded"
+(Query*)topRatedVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventFeaturedVideosLoaded @"featuredVideosLoaded"
+(Query*)featuredVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventMostViewedVideosLoaded @"mostViewedVideosLoaded"
+(Query*)mostViewedVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventQueryVideosLoaded @"queryVideosLoaded"
+(Query*)queryVideos:(NSString*)query showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventPlaylistVideosLoaded @"playlistVideosLoaded"
+(Query*)playlistVideos:(GDataEntryYouTubePlaylistLink*)playlist showMode:(int)mode withPrio:(int) delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventWatchLaterVideosLoaded @"watchLaterVideosLoaded"
+(Query*)watchLaterVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventFavoriteVideosLoaded @"favoriteVideosLoaded"
+(Query*)favoriteVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventHistoryVideosLoaded @"historyVideosLoaded"
+(Query*)historyVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventMyVideosLoaded @"myVideosLoaded"
+(Query*)myVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

// video actions

#define eventVideoLiked @"videoLiked"
+(Query*)likeVideo:(GDataEntryYouTubeVideo*)video;

#define eventVideoUnliked @"videoUnliked"
+(Query*)unlikeVideo:(GDataEntryYouTubeVideo*)video;

#define eventAddedVideoToPlaylist @"addedVideoToPlaylist"
+(Query*)addVideo:(GDataEntryYouTubeVideo*)video toPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventRemovedVideoFromPlaylist @"removedVideoFromPlaylist"
+(Query*)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventAddedVideoToFavorites @"addedVideoToFavorites"
+(Query*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video;

#define eventRemovedVideoFromFavorites @"removedVideoFromFavorites"
+(Query*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video;

#define eventAddedVideoToWatchLater @"addedVideoToWatchLater"
+(Query*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video;

#define eventRemovedVideoFromWatchLater @"removedVideoFromWatchLater"
+(Query*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video;

#define eventDeletedMyVideo @"deletedMyVideo"
+(Query*)deleteMyVideo:(GDataEntryYouTubeVideo*)video;

// playlist

#define eventPlaylistsLoaded @"playlistsLoaded"
+(Query*)playlistsOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventAddedPlaylist @"addedPlaylist"
+(Query*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventDeletedPlaylist @"deletedPlaylist"
+(Query*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventQueryPlaylistsLoaded @"queryPlaylistsLoaded"
+(Query*)queryPlaylists:(NSString*)query showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

// comment

#define eventVideoCommentsLoaded @"videoCommentsLoaded"
+(Query*)videoComments:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

#define eventAddedCommentToVideo @"addedCommentToVideo"
+(Query*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video;

#define eventDeletedCommentFromVideo @"deletedCommentFromVideo"
+(Query*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video;

// fetch more

#define eventFetchMoreLoaded @"fetchMoreLoaded"
+(Query*)fetchMore:(GDataFeedBase*)feed showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;

@end