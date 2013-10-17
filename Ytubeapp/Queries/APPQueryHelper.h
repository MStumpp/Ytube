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
#import "DataCache.h"

@interface APPQueryHelper : NSObject

#define eventVideoWatched @"videoWatched"

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

#define eventWillRemoveVideoFromFavorites @"willRemoveVideoFromFavorites"
#define eventRemovedVideoFromFavorites @"removedVideoFromFavorites"
+(Query*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video;

#define eventAddedVideoToWatchLater @"addedVideoToWatchLater"
+(Query*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video;

#define eventWillRemoveVideoFromWatchLater @"willRemoveVideoFromWatchLater"
#define eventRemovedVideoFromWatchLater @"removedVideoFromWatchLater"
+(Query*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video;

#define eventDeletedMyVideo @"deletedMyVideo"
+(Query*)deleteMyVideo:(GDataEntryYouTubeVideo*)video;

// playlist

#define eventAddedPlaylist @"addedPlaylist"
+(Query*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

#define eventDeletedPlaylist @"deletedPlaylist"
+(Query*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist;

// comment

#define eventAddedCommentToVideo @"addedCommentToVideo"
+(Query*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video;

#define eventDeletedCommentFromVideo @"deletedCommentFromVideo"
+(Query*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video;

@end