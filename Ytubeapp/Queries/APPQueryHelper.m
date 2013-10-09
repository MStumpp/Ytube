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
            context:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoLiked object:self userInfo:info];
          }
      }];
}

+(Query*)unlikeVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoUnlikeVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:[NSMutableDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoUnliked object:self userInfo:info];
          }
      }];
}



+(Query*)addVideo:(GDataEntryYouTubeVideo*)video toPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAddVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", playlist, @"playlist", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToPlaylist object:self userInfo:info];
          }
      }];
}

+(Query*)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistRemoveVideo instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", playlist, @"playlist", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromPlaylist object:self userInfo:info];
          }
      }];
}

+(Query*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddToFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToFavorites object:self userInfo:info];
          }
      }];
}

+(Query*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoRemoveFromFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromFavorites object:self userInfo:info];
          }
      }];
}

+(Query*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddToWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToWatchLater object:self userInfo:info];
          }
      }];
}

+(Query*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoRemoveFromWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromWatchLater object:self userInfo:info];
          }
      }];
}

+(Query*)deleteMyVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoMyVideoDelete instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedMyVideo object:self userInfo:info];
          }
      }];
}

// playlist

+(Query*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAdd instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedPlaylist object:self userInfo:info];
          }
      }];
}

+(Query*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistDelete instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedPlaylist object:self userInfo:info];
          }
      }];
}

// Comments

+(Query*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddComment instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedCommentToVideo object:self userInfo:info];
          }
      }];
}

+(Query*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoDeleteComment instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
            context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", comment, @"comment", nil]
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              NSMutableDictionary *info = [NSMutableDictionary new];
              [info setValue:data forKey:@"data"];
              [info setValue:error forKey:@"error"];
              [info setValue:context forKey:@"context"];
              [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedCommentFromVideo object:self userInfo:info];
          }
      }];
}

@end