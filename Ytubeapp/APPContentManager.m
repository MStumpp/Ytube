//
//  APPVideoManager.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 10.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPContentManager.h"
#import "APPQueryFetchFeedWithURL.h"
#import "APPQueryFetchEntryByInsertingEntry.h"
#import "APPQueryDeleteEntry.h"

#define tTodayStr @"today"
#define tWeekStr @"this_week"
#define tMonthStr @"this_month"
#define tAllStr @"all_time"

@interface APPContentManager()
@property (strong, nonatomic) GDataServiceGoogleYouTube *service;

// temp tickets

@property (strong, nonatomic) GDataServiceTicket *likeTicket;
@property (strong, nonatomic) GDataServiceTicket *watchLaterTicket;
@property (strong, nonatomic) GDataServiceTicket *favoritesTicket;

@property (strong, nonatomic) APPQueryManager *queryManager;

@end

@implementation APPContentManager

static APPContentManager *classInstance = nil;

+(APPContentManager*)classInstance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:NULL] init];
        classInstance.queryManager = [APPQueryManager initWithService:classInstance.service];
    }
    return classInstance;
}

//////
// Videos
//////

-(APPQueryTicket*)recentlyFeaturedWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/recently_featured"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)mostPopular:(int)time prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/most_popular?time=%@", [self timeString:time]]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)topRated:(int)time prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_rated?time=%@", [self timeString:time]]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)topFavorites:(int)time prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_favorites?time=%@", [self timeString:time]]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)queryVideos:(NSString*)query prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@", query]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)historyWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/watch_history?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)relatedVideos:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@/related", [self videoID:video]]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

//////
// Like / Dislike
//////

-(APPQueryTicket*)likeVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeVideo* video, NSError *error))callback
{
    /*if (self.likeTicket)
        [self.likeTicket cancelTicket];*/
    
    [[video rating] setValue:@"like"];
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error){
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubeVideo*)object, nil);
        }        
    }] fetchEntryByInsertingEntry:video forFeedURL:[[video ratingsLink] URL]] prio:prio];
}

-(APPQueryTicket*)dislikeVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeVideo* video, NSError *error))callback
{
    /*if (self.likeTicket)
        [self.likeTicket cancelTicket];*/
    
    [[video rating] setValue:@"dislike"];
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubeVideo*)object, nil);
        }        
    }] fetchEntryByInsertingEntry:video forFeedURL:[[video ratingsLink] URL]] prio:prio];
}

-(void)likeStateOfVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(NSInteger state))callback
{
    if ([[[video rating] value] isEqualToString:@"like"])
        callback(tLikeLike);
    else if ([[[video rating] value] isEqualToString:@"dislike"])
        callback(tLikeDislike);
    else
        callback(tLike);
}

//////
// Comments
//////

-(APPQueryTicket*)comments:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:[[[video comment] feedLink] URL]] prio:prio];    
}

-(APPQueryTicket*)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeComment *comment, NSError *error))callback
{    
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubeComment*)object, nil);
        }
    }] fetchEntryByInsertingEntry:comment forFeedURL:[[[video comment] feedLink] URL]] prio:prio];
}

-(APPQueryTicket*)deleteComment:(GDataEntryYouTubeComment*)comment prio:(int)prio context:(id)context callback:(void (^)(BOOL deleted, NSError *error))callback
{
    return [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(FALSE, error);
        } else {
            if (callback)
                callback(TRUE, nil);
        }
    }] deleteEntry:comment] prio:prio];
}

//////
// My Videos
//////

-(APPQueryTicket*)myVideoWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{    
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/uploads"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)deleteMyVideo:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL deleted, NSError *error))callback;
{
    return [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(FALSE, error);
        } else {
            if (callback)
                callback(TRUE, nil);
        }
    }] deleteEntry:video] prio:prio];
}

//////
// Playlists
//////

-(APPQueryTicket*)playlistsWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/playlists?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)addPlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylistLink *playlist, NSError *error))callback
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/playlists?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubePlaylistLink*)object, nil);
        }
    }] fetchEntryByInsertingEntry:playlist forFeedURL:feedURL] prio:prio];
}

-(APPQueryTicket*)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(BOOL deleted, NSError *error))callback
{
    return [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(FALSE, error);
        } else {
            if (callback)
                callback(TRUE, nil);
        }
    }] deleteEntry:playlist] prio:prio];
}

-(APPQueryTicket*)videosForPlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[[playlist content] sourceURI]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];    
}

-(APPQueryTicket*)addVideoToPlaylist:(GDataEntryYouTubeVideo*)video playlist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylist *entry, NSError *error))callback
{
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubePlaylist*)object, nil);
        }
    }] fetchEntryByInsertingEntry:video forFeedURL:[[playlist editLink] URL]] prio:prio];
}

-(APPQueryTicket*)removeVideoFromPlaylist:(GDataEntryYouTubePlaylist*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL removed, NSError *error))callback
{
    return [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(FALSE, error);
        } else {
            if (callback)
                callback(TRUE, nil);
        }
    }] deleteEntry:video] prio:prio];
}

-(APPQueryTicket*)queryPlaylists:(NSString*)query prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/snippets?q=%@", query]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];
}

//////
// Watch Later
//////

-(APPQueryTicket*)videosForWatchLaterWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];    
}

-(APPQueryTicket*)videosForWatchLaterWithPrio:(int)prio context:(id)context callback:(void (^)(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error))callback
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (callback)
            callback(nil, (GDataFeedBase*)object, error);
    }] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)addVideoToWatchLater:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylist *entry, NSError *error))callback
{
    //if (self.watchLaterTicket)
    //    [self.watchLaterTicket cancelTicket];
    
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/watch_later?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubePlaylist*)object, nil);
        }
    }] fetchEntryByInsertingEntry:video forFeedURL:feedURL] prio:prio];
}

-(APPQueryTicket*)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL removed, NSError *error))callback
{
    //if (self.watchLaterTicket)
    //    [self.watchLaterTicket cancelTicket];
    
    if ([video isMemberOfClass:[GDataEntryYouTubePlaylist class]]) {
        
        return [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
            if (error) {
                if (callback)
                    callback(FALSE, error);
            } else {
                if (callback)
                    callback(TRUE, nil);
            }
        }] deleteEntry:video] prio:prio];
                
    } else {
    
        return [self isVideoWatchLater:video prio:prio context:context callback:^(GDataEntryYouTubePlaylist *tmp_video, NSError *error) {
            if (error) {
                if (callback)
                    callback(FALSE, error);
                
            } else {
                
                if (tmp_video) {
                    [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
                        if (error) {
                            if (callback)
                                callback(FALSE, error);
                        } else {
                            if (callback)
                                callback(TRUE, nil);
                        }
                    }] deleteEntry:tmp_video] prio:prio];
                                        
                } else {
                    if (callback)
                        callback(FALSE, nil);
                }
            }
        }];
    }
}

-(APPQueryTicket*)isVideoWatchLater:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubePlaylist *video, NSError *error))callback
{
    return [self videosForWatchLaterWithPrio:prio context:context callback:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        
        } else {
            
            if (feed != nil) {
                GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
                for (GDataEntryBase *entryBase in [feed entries]) {
                    GDataYouTubeMediaGroup *mediaGroupEntry = [(GDataEntryYouTubeVideo *)entryBase mediaGroup];
                    if ([[mediaGroupVideo videoID] isEqualToString:[mediaGroupEntry videoID]]) {
                        if (callback)
                            callback((GDataEntryYouTubePlaylist *) entryBase, nil);
                        return;
                    }
                }
            }
            if (callback)
                callback(nil, nil);
        }
    }];
}

//////
// Favorites
//////

-(APPQueryTicket*)favoritesWithPrio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/favorites?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:feedURL] prio:prio];    
}

-(APPQueryTicket*)favoritesWithPrio:(int)prio context:(id)context callback:(void (^)(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error))callback
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/favorites?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (callback)
            callback(nil, (GDataFeedBase*)object, error);
    }] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)addVideoToFavorites:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeFavorite *favorite, NSError *error))callback
{
    //if (self.favoritesTicket)
    //    [self.favoritesTicket cancelTicket];
        
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/favorites?v=2"]];
    return [self.queryManager process:[[[APPQueryFetchEntryByInsertingEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        } else {
            if (callback)
                callback((GDataEntryYouTubeFavorite*)object, nil);
        }
    }] fetchEntryByInsertingEntry:video forFeedURL:feedURL] prio:prio];
}

-(APPQueryTicket*)removeVideoFromFavorites:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(BOOL removed, NSError *error))callback
{
    //if (self.favoritesTicket)
    //    [self.favoritesTicket cancelTicket];
    
    if ([video isMemberOfClass:[GDataEntryYouTubeFavorite class]]) {
        
        return [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
            if (error) {
                if (callback)
                    callback(FALSE, error);
            } else {
                if (callback)
                    callback(TRUE, nil);
            }
        }] deleteEntry:video] prio:prio];
        
    } else {
        
        return [self isVideoFavorite:video prio:prio context:context callback:^(GDataEntryYouTubeFavorite *tmp_video, NSError *error) {
            if (error) {
                if (callback)
                    callback(FALSE, error);
            
            } else {
            
                if (tmp_video) {
                    [self.queryManager process:[[[APPQueryDeleteEntry alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
                        if (error) {
                            if (callback)
                                callback(FALSE, error);
                        } else {
                            if (callback)
                                callback(TRUE, nil);
                        }
                    }] deleteEntry:tmp_video] prio:prio];
                    
                } else {
                    if (callback)
                        callback(FALSE, nil);
                }
            }
        }];
    }
}

-(APPQueryTicket*)isVideoFavorite:(GDataEntryYouTubeVideo*)video prio:(int)prio context:(id)context callback:(void (^)(GDataEntryYouTubeFavorite *favorite, NSError *error))callback
{
    return [self favoritesWithPrio:prio context:context callback:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
        if (error) {
            if (callback)
                callback(nil, error);
        
        } else {
    
            if (feed != nil) {
                GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
                for (GDataEntryBase *entryBase in [feed entries]) {
                    GDataYouTubeMediaGroup *mediaGroupEntry = [(GDataEntryYouTubeVideo *)entryBase mediaGroup];
                    if ([[mediaGroupVideo videoID] isEqualToString:[mediaGroupEntry videoID]]) {
                        if (callback)
                            callback((GDataEntryYouTubeFavorite *) entryBase, nil);
                        return;
                    }
                }
            }
            if (callback)
                callback(nil, nil);
        }
    }];
}

//////
// Channels
//////

/*-(void)channelsDelegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/uploads"]];
    [[self service] fetchFeedWithURL:feedURL delegate:del didFinishSelector:sel];
}

-(void)queryChannels:(NSString*)query delegate:(id)del didFinishSelector:(SEL)sel
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/channels?q=%@", query]];
    [[self service] fetchFeedWithURL:feedURL delegate:del didFinishSelector:sel];
}*/

//////
// Images
//////

-(void)imageForVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback
{
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    NSArray *thumbnails = [mediaGroup mediaThumbnails];
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:0] URLString]]];
        UIImage * image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
    dispatch_release(downloadQueue);
}

-(void)imageLargeForVideo:(GDataEntryYouTubeVideo*)video callback:(void (^)(UIImage *image))callback
{
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    NSArray *thumbnails = [mediaGroup mediaThumbnails];
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:3] URLString]]];
        UIImage * image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
    dispatch_release(downloadQueue);
}

-(void)imageLoader:(NSString*)url callback:(void (^)(UIImage *image))callback
{
    if (url) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(image);
                    return;
                }
            });
        });
        dispatch_release(downloadQueue);
    }
}

-(APPQueryTicket*)imageForPlaylist:(GDataEntryYouTubePlaylistLink*)playlist prio:(int)prio context:(id)context callback:(void (^)(UIImage *image))callback
{
    NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[playlist content] sourceURI], @"&max-results=1"]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error == nil) {
            GDataEntryBase *entry = [[(GDataFeedBase*)object entries] objectAtIndex:0];
            GDataEntryYouTubeVideo *ytvideo = (GDataEntryYouTubeVideo *) entry;
            GDataYouTubeMediaGroup *mediaGroup = [ytvideo mediaGroup];
            
            NSArray *thumbnails = [mediaGroup mediaThumbnails];
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[thumbnails objectAtIndex:0] URLString]]];
                UIImage * image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback)
                        callback(image);
                });
            });
            dispatch_release(downloadQueue);
            
        } else {
            if (callback)
                callback(nil);
        }
    }] fetchFeedWithURL:feedURL] prio:prio];
}

-(APPQueryTicket*)imageForComment:(GDataEntryYouTubeComment*)comment prio:(int)prio context:(id)context callback:(void (^)(UIImage *image))callback
{
    NSURL *feedURL = [NSURL URLWithString:[[[comment authors] objectAtIndex:0] URI]];
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andCompletionHandler:^(APPQuery *query, id object, id context, NSError *error) {
        if (error == nil) {
            GDataEntryYouTubeUserProfile *profile = (GDataEntryYouTubeUserProfile*)object;
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[profile thumbnail] URLString]]];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback)
                        callback(image);
                });
            });
            dispatch_release(downloadQueue);
            
        } else {
            if (callback)
                callback(nil);
        }
    }] fetchFeedWithURL:feedURL] prio:prio];
}

//////
// Load more data
//////

-(APPQueryTicket*)loadMoreData:(GDataFeedBase*)feed prio:(int)prio context:(id)context delegate:(id)del didFinishSelector:(SEL)sel
{
    return [self.queryManager process:[[[APPQueryFetchFeedWithURL alloc] initWithContext:context andDelegate:del andSelector:sel] fetchFeedWithURL:[[feed nextLink] URL]] prio:prio];    
}

//////
// helpers
//////

-(BOOL)isUser:(GDataEntryYouTubeUserProfile*)user authorOf:(GDataEntryBase*)entry;
{
    if (!user || !entry)
        return FALSE;
    
    NSEnumerator *e = [[entry authors] objectEnumerator];
    id object;
    while (object = [e nextObject]) {
        if ([[object name] isEqualToString:[(GDataPerson*)[[user authors] objectAtIndex:0] name]]) {
            return TRUE;
        }
    }
    return FALSE;
}

//////
// private helpers
//////

- (NSString*)videoID:(GDataEntryYouTubeVideo *)video
{
    GDataYouTubeMediaGroup *mediaGroupVideo = [video mediaGroup];
    return [mediaGroupVideo videoID];
}

- (NSString*)timeString:(int)timeKey
{
    switch (timeKey)
    {
        case tToday:
        {
            return tTodayStr;
            break;
        }
        case tWeek:
        {
            return tWeekStr;
            break;
        }
        case tMonth:
        {
            return tMonthStr;
            break;
        }
        default:
        {
            return tAllStr;
            break;
        }
    }
}

@end
