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
#import "APPPlaylistImageOfPlaylist.h"
#import "APPVideoDeleteComment.h"
#import "APPVideoRelatedVideos.h"
#import "APPVideoTopFavorites.h"
#import "APPVideoTopRated.h"
#import "APPVideoRecentlyFeatured.h"
#import "APPVideoMostViewed.h"

@implementation APPQueryHelper

// video

+(QueryTicket*)relatedVideos:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoRelatedVideos instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventRelatedVideosLoaded object:dict];
                    [delegate reloadDataResponse:dict];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)topFavoriteVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoTopFavorites instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:mode, tMode, nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventTopFavoriteVideosLoaded  object:dict];
                    [delegate reloadDataResponse:dict];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)topRatedVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoTopRated instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:nil onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventTopRatedVideosLoaded  object:dict];
                    [delegate reloadDataResponse:dict];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)featuredVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoRecentlyFeatured instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:nil onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventFeaturedVideosLoaded  object:dict];
                    [delegate reloadDataResponse:dict];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)mostViewedVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoMostViewed instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process: onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventMostViewedVideosLoaded  object:dict];
                    [delegate reloadDataResponse:dict];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)searchVideos:(NSString*)query showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{

}

+(QueryTicket*)playlistVideos:(GDataEntryYouTubePlaylistLink*)playlist showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{

}

+(QueryTicket*)watchLaterVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{

}

+(QueryTicket*)favoriteVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{

}

+(QueryTicket*)historyVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{

}

+(QueryTicket*)myVideosOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{

}

+(QueryTicket*)likeVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoLikeVideo instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventRelatedVideosLoaded object:[NSDictionary dictionaryWithObjectsAndKeys:(GDataEntryYouTubeVideo*)data, @"video", nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)unlikeVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoUnlikeVideo instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoUnliked object:[NSDictionary dictionaryWithObjectsAndKeys:(GDataEntryYouTubeVideo*)data, @"video", nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)addVideo:(GDataEntryYouTubeVideo*)video toPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAddVideo instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToPlaylist object:[NSDictionary dictionaryWithObjectsAndKeys:(GDataEntryYouTubeVideo*)data, @"video", playlist, @"playlist", nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistRemoveVideo instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromPlaylist object:[NSDictionary dictionaryWithObjectsAndKeys:(GDataEntryYouTubeVideo*)data, @"video", playlist, @"playlist", nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddToFavorites instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToFavorites object:(GDataEntryYouTubeVideo*)data];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoRemoveFromFavorites instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromFavorites object:(GDataEntryYouTubeVideo*)data];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoAddToWatchLater instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedVideoToWatchLater object:(GDataEntryYouTubeVideo*)data];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoRemoveFromWatchLater instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventRemovedVideoFromWatchLater object:(GDataEntryYouTubeVideo*)data];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)deleteMyVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoMyVideoDelete instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedMyVideo object:(GDataEntryYouTubeVideo*)data];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

// playlist

+(QueryTicket*)playlistsOnShowMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPPlaylists instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:nil onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [delegate reloadDataResponse:[NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
            default:
            {
                NSLog(@"APPPlaylists: default");
                break;
            }
        }
    }];
}

+(QueryTicket*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistAdd instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedPlaylist object:playlist];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"We could not add your playlist. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
            default:
            {
                NSLog(@"APPPlaylistAdd: default");
                break;
            }
        }
    }];
}

+(QueryTicket*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    return [[APPPlaylistDelete instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedPlaylist object:playlist];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to delete your playlist. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
            default:
            {
                NSLog(@"APPPlaylistDelete: default");
                break;
            }
        }
    }];
}

// Comments

// TODO: consider prio to add to the right queue
+(QueryTicket*)videoComments:(GDataEntryYouTubeVideo*)video showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate
{
    return [[APPVideoComments instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [delegate reloadDataResponse:[NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

+(QueryTicket*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPPlaylistImageOfPlaylist instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", video, @"video", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventAddedCommentToVideo object:video];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"We could not add your comment. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
            default:
            {
                NSLog(@"APPVideoAddComment: default");
                break;
            }
        }
    }];
}

+(QueryTicket*)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video
{
    return [[APPVideoDeleteComment instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:eventDeletedCommentFromVideo object:video];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to delete your comment. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
            default:
            {
                NSLog(@"APPVideoDeleteComment: default");
                break;
            }
        }
    }];
}

// fetch more

+(QueryTicket*)fetchMore:(GDataFeedBase*)feed showMode:(int)mode withPrio:(int)prio delegate:(id<APPTableViewProcessResponse>)delegate;
{
    return [[APPFetchMoreQuery instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:feed, @"feed", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    [delegate loadMoreDataResponse:[NSDictionary dictionaryWithObjectsAndKeys:(GDataFeedBase*)data, tFeed, error, tError, nil]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                message:[NSString stringWithFormat:@"Unable to fetch more data. Please try again later."]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
                break;
            }
        }
    }];
}

@end