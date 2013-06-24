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

// video

#define eventVideoLiked @"videoLiked"
#define eventVideoUnliked @"videoUnliked"

#define eventAddedVideoToPlaylist @"addedVideoToPlaylist"
#define eventRemovedVideoFromPlaylist @"removedVideoFromPlaylist"

#define eventAddedVideoToFavorites @"addedVideoToFavorites"
#define eventRemovedVideoFromFavorites @"removedVideoFromFavorites"

#define eventAddedVideoToWatchLater @"addedVideoToWatchLater"
#define eventRemovedVideoFromWatchLater @"removedVideoFromWatchLater"

#define eventDeletedMyVideo @"deletedMyVideo"

// playlist

#define eventAddedPlaylist @"addedPlaylist"
#define eventDeletedPlaylist @"deletedPlaylist"

// comment

#define eventAddedCommentToVideo @"addedCommentToVideo"
#define eventDeletedCommentFromVideo @"deletedCommentFromVideo"

@interface APPQueryHelper : NSObject

// video

+(QueryTicket*)relatedVideos:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;
+(QueryTicket*)commentsForVideo:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;
+(QueryTicket*)likeVideo:(GDataEntryYouTubeVideo*)video;
+(QueryTicket*)unlikeVideo:(GDataEntryYouTubeVideo*)video;
+(QueryTicket*)videoComments:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

+(QueryTicket*)addVideo:(GDataEntryYouTubeVideo*)video toPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;
+(QueryTicket*)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

+(QueryTicket*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video;
+(QueryTicket*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video;

+(QueryTicket*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video;
+(QueryTicket*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video;

+(QueryTicket*)deleteMyVideo:(GDataEntryYouTubeVideo*)video;

+(QueryTicket*)fetchMore:(GDataFeedBase*)feed showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;

// playlist

+(QueryTicket*)playlistsOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;
+(QueryTicket*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;
+(QueryTicket*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

// comment

+(QueryTicket*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video;
+(QueryTicket*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video;

@end