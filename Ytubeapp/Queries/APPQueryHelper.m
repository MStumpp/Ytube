//
// Created by Matthias Stumpp on 23.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPQueryHelper.h"
#import "APPVideoLikeVideo.h"
#import "APPVideoUnlikeVideo.h"
#import "APPVideoMyVideoDelete.h"
#import "APPVideoRemoveFromWatchLater.h"
#import "APPVideoAddToWatchLater.h"
#import "APPVideoRemoveFromFavorites.h"
#import "APPVideoAddToFavorites.h"
#import "APPPlaylistRemoveVideo.h"
#import "APPPlaylistAddVideo.h"
#import "APPPlaylistDelete.h"
#import "APPPlaylistAdd.h"
#import "APPVideoDeleteComment.h"
#import "APPVideoAddComment.h"

@implementation APPQueryHelper

// video actions

+(Query*)likeVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoLikeVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedMyVideo object:data];
          }
      }];
}

// playlist

+(Query*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAdd instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedPlaylist object:data];
          }
      }];
}

// Comments

+(Query*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddComment instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
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
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (error) {
                  [self showErrorMessage];
              }
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedCommentFromVideo object:data];
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