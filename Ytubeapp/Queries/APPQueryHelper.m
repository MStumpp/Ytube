//
// Created by Matthias Stumpp on 23.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPQueryHelper.h"
#import "APPFetchMoreQuery.h"
#import "APPVideoLikeVideo.h"
#import "APPVideoUnlikeVideo.h"
#import "APPVideoComments.h"
#import "APPVideoMyVideoDelete.h"
#import "APPVideoRemoveFromWatchLater.h"
#import "APPVideoAddToWatchLater.h"
#import "APPVideoRemoveFromFavorites.h"
#import "APPVideoAddToFavorites.h"
#import "APPPlaylistRemoveVideo.h"
#import "APPPlaylistAddVideo.h"
#import "APPPlaylistDelete.h"
#import "APPPlaylistAdd.h"
#import "APPPlaylists.h"
#import "APPVideoDeleteComment.h"
#import "APPVideoRelatedVideos.h"
#import "APPVideoTopFavorites.h"
#import "APPVideoTopRated.h"
#import "APPVideoRecentlyFeatured.h"
#import "APPVideoMostViewed.h"
#import "APPWatchLater.h"
#import "APPFavorites.h"
#import "APPVideoWatchHistory.h"
#import "APPVideoMyVideos.h"
#import "APPVideoAddComment.h"
#import "APPVideoQuery.h"
#import "APPPlaylistVideos.h"
#import "APPPlaylistQuery.h"

@implementation APPQueryHelper

// video showing (APPTableView)

+(Query*)relatedVideos:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: relatedVideos: request");
    return [[APPVideoRelatedVideos instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
        execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", @(mode), tMode, nil]
        withPrio:p
        onStateChange:^(NSString *state, id data) {
        if ([state isEqual:tFinished]) {
            NSLog(@"APPQueryHelper: relatedVideos: response");
            if (![(NSDictionary*)data objectForKey:@"error"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:eventRelatedVideosLoaded object:data];
                [delegate reloadDataResponse:data];
            } else {
                [self showErrorMessage];
            }
        }
    }];
}

+(Query*)topFavoriteVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: topFavoriteVideosOnShowMode: request");
    return [[APPVideoTopFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: topFavoriteVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventTopFavoriteVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)topRatedVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: topRatedVideosOnShowMode: request");
    return [[APPVideoTopRated instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: topRatedVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventTopRatedVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)featuredVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: featuredVideosOnShowMode: request");
    return [[APPVideoRecentlyFeatured instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: featuredVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventFeaturedVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)mostViewedVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: mostViewedVideosOnShowMode: request");
    return [[APPVideoMostViewed instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  NSLog(@"APPQueryHelper: mostViewedVideosOnShowMode: response");
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventMostViewedVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)queryVideos:(NSString*)query showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;
{
    NSLog(@"APPQueryHelper: queryVideos: request");
    return [[APPVideoQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, query, @"query", nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: queryVideos: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventQueryVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)playlistVideos:(GDataEntryYouTubePlaylistLink*)playlist showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: playlistVideos: request");
    return [[APPPlaylistVideos instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, playlist, @"playlist", nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: playlistVideos: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventPlaylistVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)watchLaterVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: watchLaterVideosOnShowMode: request");
    return [[APPWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: watchLaterVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventWatchLaterVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)favoriteVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: favoriteVideosOnShowMode: request");
    return [[APPFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: favoriteVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventFavoriteVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)historyVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: historyVideosOnShowMode: request");
    return [[APPVideoWatchHistory instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: historyVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventHistoryVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

+(Query*)myVideosOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    NSLog(@"APPQueryHelper: myVideosOnShowMode: request");
    return [[APPVideoMyVideos instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              NSLog(@"APPQueryHelper: myVideosOnShowMode: response");
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventMyVideosLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

// video actions

+(Query*)likeVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoLikeVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoLiked object:data];
          }
      }];
}

+(Query*)unlikeVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoUnlikeVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoUnliked object:data];
          }
      }];
}



+(Query*)addVideo:(GDataEntryYouTubeVideo*)video toPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAddVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToPlaylist object:data];
          }
      }];
}

+(Query*)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistRemoveVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromPlaylist object:data];
          }
      }];
}

+(Query*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddToFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToFavorites object:data];
          }
      }];
}

+(Query*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoRemoveFromFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromFavorites object:data];
          }
      }];
}

+(Query*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddToWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToWatchLater object:data];
          }
      }];
}

+(Query*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoRemoveFromWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromWatchLater object:data];
          }
      }];
}

+(Query*)deleteMyVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoMyVideoDelete instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedMyVideo object:data];
          }
      }];
}

// playlist

+(Query*)playlistsOnShowMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPPlaylists instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:@(mode), @"mode", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventPlaylistsLoaded object:data];
          }
      }];
}

+(Query*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAdd instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedPlaylist object:data];
          }
      }];
}

+(Query*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistDelete instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedPlaylist object:data];
          }
      }];
}

+(Query*)queryPlaylists:(NSString*)query showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;
{
    return [[APPPlaylistQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(mode), tMode, query, @"query", nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventQueryPlaylistsLoaded object:data];
                  [delegate reloadDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

// Comments

+(Query*)videoComments:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoComments instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", @(mode), @"mode", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoCommentsLoaded object:data];
          }
      }];
}

+(Query*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddComment instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedCommentToVideo object:data];
          }
      }];
}

+(Query*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoDeleteComment instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if ([(NSDictionary*)data objectForKey:@"error"]) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedCommentFromVideo object:data];
          }
      }];
}

// fetch more

+(Query*)fetchMore:(GDataFeedBase*)feed showMode:(int)mode withPrio:(int)p delegate:(id<APPTableViewProcessResponse>)delegate;
{
    return [[APPFetchMoreQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:feed, @"feed", @(mode), @"mode", nil]
           withPrio:p
      onStateChange:^(NSString *state, id data) {
          if ([state isEqual:tFinished]) {
              if (![(NSDictionary*)data objectForKey:@"error"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:eventFetchMoreLoaded object:data];
                  [delegate loadMoreDataResponse:data];
              } else {
                  [self showErrorMessage];
              }
          }
      }];
}

// show error message

+(void)showErrorMessage
{
    NSLog(@"error");
//    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
//    message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
//    delegate:nil
//    cancelButtonTitle:@"OK"
//    otherButtonTitles:nil] show];
}

@end