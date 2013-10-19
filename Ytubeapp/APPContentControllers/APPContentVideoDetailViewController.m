//
//  APPContentVideoDetailViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.10.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPQueryHelper.h"
#import "APPVideoCell.h"
#import "APPContentVideoDetailViewController.h"
#import "APPContent.h"
#import "APPVideoIsFavorite.h"
#import "APPVideoIsWatchLater.h"
#import "APPCommentCell.h"
#import "APPContentPlaylistListController.h"
#import "APPContentCommentListController.h"
#import "APPVideoRelatedVideos.h"
#import "APPVideoComments.h"
#import "APPFetchMoreQuery.h"

#define tRelatedVideosAll @"related_videos_all"
#define tCommentsVideosAll @"comments_videos_all"
#define tRelatedVideos 01
#define tCommentsVideos 02

@interface APPContentVideoDetailViewController()
@property UIWebView *webView;
@property APPTableView *tableView;
@property UITableViewHeaderFormView *tableViewHeaderFormView;
@property UIButton *backButton;
@property UIButton *likeButton;
@property UIButton *watchLaterButton;
@property UIButton *favoritesButton;
@property BOOL favoritesFetching;
@property BOOL watchLaterFetching;
@property BOOL favoritesFetched;
@property BOOL watchLaterFetched;
@property UIButton *commentButton;
@property UIButton *addToPlaylistButton;
@property BOOL subtopbarWasVisible;
@property NSDictionary *buttons;
@property NSDictionary *keyConvert;
@property NSString *relatedVideosId;
@property NSString *commentsId;
// for comment cell opening/closing
@property NSInteger rowOpenHeight;
@property NSIndexPath *openSubMenuCell;
@property NSIndexPath *openCommentCell;
@property NSIndexPath *wasOpenCommentCell;
@property BOOL *wasVideoPlaying;
@end

@implementation APPContentVideoDetailViewController
@synthesize video;

-(id)initWithVideo:(GDataEntryYouTubeVideo*)v
{
    self = [super init];
    if (self) {
        self.video = v;
        self.topbarTitle = [[self.video title] stringValue];

        self.relatedVideosId = [NSString stringWithFormat:@"%@_%@", tRelatedVideosAll, [APPContent videoID:self.video]];
        self.commentsId = [NSString stringWithFormat:@"%@_%@", tCommentsVideosAll, [APPContent videoID:self.video]];
        
        self.keyConvert = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tRelatedVideos], self.relatedVideosId,
                           [NSNumber numberWithInt:tCommentsVideos], self.commentsId, nil];
        
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toDefaultShowMode];
        }];
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // save state of header form
            if ([self.tableViewHeaderFormView isHeaderShown]) {
                self.subtopbarWasVisible = TRUE;
                [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
            } else {
                self.subtopbarWasVisible = FALSE;
            }
            
            // close open cell if one is open
            if ([self.tableView openCell]) {
                self.openSubMenuCell = [self.tableView openCell];
                [self.tableView closeCell:[self.tableView openCell] onCompletion:nil];
            } else {
                self.openSubMenuCell = nil;
            }
            
            // close open comment cell
            if (self.openCommentCell) {
                self.wasOpenCommentCell = self.openCommentCell;
                [self tapCell:self.openCommentCell];
            } else {
                self.wasOpenCommentCell = nil;
            }
            
            if ([self isVideoPlaying])
                self.wasVideoPlaying = TRUE;
            else
                self.wasVideoPlaying = FALSE;
            [self pauseVideo];
        }];
        
        [[self configureState:tActiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // show header form if was visible
            if (self.subtopbarWasVisible) {
                [self.tableViewHeaderFormView showOnCompletion:nil animated:NO];
            }
            
            // open cell if one was opened
            if (self.openSubMenuCell) {
                [self.tableView openCell:self.openSubMenuCell onCompletion:nil];
            }
            
            // open comment cell if one was open previously
            if (self.wasOpenCommentCell) {
                [self tapCell:self.wasOpenCommentCell];
            }
            
            if (self.wasVideoPlaying)
                [self playVideo];
        }];
        
        // configure tVideoDetailAll as default state
        [self setDefaultState:self.relatedVideosId];
        
        
        [[self configureState:self.commentsId] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:self.commentsId];
        }];
        
        [self.dataCache configureReloadDataForKey:self.commentsId withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPVideoComments instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        
        [self.dataCache configureReloadDataForKey:self.relatedVideosId withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPVideoRelatedVideos instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [self.dataCache configureLoadMoreDataForKeys:@[self.commentsId, self.relatedVideosId] withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
            queryHandler(key, [[APPFetchMoreQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSDictionary dictionaryWithObjectsAndKeys:previous, @"feed", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillAddVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillRemoveVideoFromFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillAddVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillRemoveVideoFromWatchLater object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventVideoLiked object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventVideoUnliked object:nil];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    //[self.view addSubview:[[UIImageView alloc] initWithImage:[[APPGlobals classInstance] getGlobalForKey:@"main_back"]]];
    
    // set up video
    ////////////////
    /*UIImageView *videoThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, heightVideoView)];
    videoThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    videoThumbnail.clipsToBounds = YES;
    [self.view addSubview:videoThumbnail];
    
    [APPContent largeImageOfVideo:self.video callback:^(UIImage *image) {
        if (image)
            [videoThumbnail setImage:image];
    }];
    
    // add play button on top of preview thumbnail
    UIImageView *videoPlayButton = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, heightVideoView)];
    [videoPlayButton setImage:[UIImage imageNamed:@"video_detail_back"]];
    [self.view addSubview:videoPlayButton];*/
                
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, heightVideoView)];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.scrollView.scrollEnabled = FALSE;
    [self.view addSubview:self.webView];

    // set up sub button bar
    /////////////////////////
    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, heightVideoView, self.view.frame.size.width, 50.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_detail_nav"]]];
    [self.view addSubview:subtopbarContainer];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0.0, 0.0, 52.0, 50.0);
    [self.backButton setTag:tBack];
    [self.backButton setImage:[UIImage imageNamed:@"video_detail_arrow_left_up"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"video_detail_arrow_left_down"] forState:UIControlStateSelected];
    [self.backButton setImage:[UIImage imageNamed:@"video_detail_arrow_left_down"] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.backButton];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.frame = CGRectMake(320.0-52.0-52.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.likeButton setTag:tLike];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_up"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
    [self.likeButton setSelected:FALSE];
    [self.likeButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.likeButton];

    self.watchLaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.watchLaterButton.frame = CGRectMake(320.0-52.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.watchLaterButton setTag:tWatchLater];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_up"] forState:UIControlStateNormal];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateSelected];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateHighlighted];
    [self.watchLaterButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.watchLaterButton setSelected:NO];
    [subtopbarContainer addSubview:self.watchLaterButton];
    
    self.favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoritesButton.frame = CGRectMake(320.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.favoritesButton setTag:tFavorites];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_up"] forState:UIControlStateNormal];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateSelected];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateHighlighted];
    [self.favoritesButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.favoritesButton setSelected:NO];
    [subtopbarContainer addSubview:self.favoritesButton];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.frame = CGRectMake(320.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.commentButton setTag:tComments];
    [self.commentButton setImage:[UIImage imageNamed:@"video_detail_comment_up"] forState:UIControlStateNormal];
    [self.commentButton setImage:[UIImage imageNamed:@"video_detail_comment_down"] forState:UIControlStateSelected];
    [self.commentButton setImage:[UIImage imageNamed:@"video_detail_comment_down"] forState:UIControlStateHighlighted];
    [self.commentButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.commentButton];
    
    self.addToPlaylistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addToPlaylistButton.frame = CGRectMake(320.0-52.0, 0.0, 52.0, 50.0);
    [self.addToPlaylistButton setTag:tAddToPlaylist];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_detail_plus_up"] forState:UIControlStateNormal];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_detail_plus_down"] forState:UIControlStateSelected];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_detail_plus_down"] forState:UIControlStateHighlighted];
    [self.addToPlaylistButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.addToPlaylistButton];
    
    [self reset];

    // set up table
    ////////////////
    self.tableView = [[APPTableView alloc] initWithFrame:CGRectMake(0.0, heightVideoView+50.0+3.0, self.view.frame.size.width, self.view.frame.size.height-(heightVideoView+50.0+3.0)) style:UITableViewStylePlain];
    self.tableView._del = self;
    [self.view addSubview:self.tableView];
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];

    UIControl *subtopbarContainer2 = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer2 addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];
    
    UIButton *commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 6.0, 132.0, 30.0)];
    [commentsButton addTarget:self action:@selector(subtopbarButtonPress2:) forControlEvents:UIControlEventTouchUpInside];
    [commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_up_2"] forState:UIControlStateNormal];
    [commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_down_2"] forState:UIControlStateHighlighted];
    [commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_down_2"] forState:UIControlStateSelected];
    [commentsButton setTag:tCommentsVideos];
    [subtopbarContainer2 addSubview:commentsButton];
    
    UIButton *relatedVideosButton = [[UIButton alloc] initWithFrame:CGRectMake(172.0, 6.0, 132.0, 30.0)];
    [relatedVideosButton addTarget:self action:@selector(subtopbarButtonPress2:) forControlEvents:UIControlEventTouchUpInside];
    [relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_up_2"] forState:UIControlStateNormal];
    [relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_down_2"] forState:UIControlStateHighlighted];
    [relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_down_2"] forState:UIControlStateSelected];
    [relatedVideosButton setTag:tRelatedVideos];
    [subtopbarContainer2 addSubview:relatedVideosButton];
    
    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer2];
    
    [self.tableView addDefaultShowMode:self.relatedVideosId];
    [self.tableView addShowMode:self.commentsId];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.buttons = [[NSDictionary alloc] initWithObjectsAndKeys:commentsButton, self.commentsId, relatedVideosButton, self.relatedVideosId, nil];
    
    [self displayGoogleVideo:[[self.video mediaGroup] videoID]];
}

-(void)userSignedIn:(NSNotification*)notification
{
    [super userSignedIn:notification];
    [self reset];
}

-(void)userSignedOut:(NSNotification*)notification
{
    [super userSignedOut:notification];
    [self reset];
}

-(void)reset
{
    self.favoritesFetching = FALSE;
    self.watchLaterFetching = FALSE;
    self.favoritesFetched = FALSE;
    self.watchLaterFetched = FALSE;
    [self.likeButton setTag:tLike];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_up"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
    [self.likeButton setSelected:FALSE];
    [self.watchLaterButton setSelected:NO];
    [self.favoritesButton setSelected:NO];
    
    [self fetchState];
}

-(void)fetchState
{
    if (![[APPUserManager classInstance] isUserSignedIn]) return;
    
    /*switch ([APPContent likeStateOfVideo:self.video])
    {
        case tLikeLike:
        {
            [self.likeButton setSelected:TRUE];
            [self.likeButton setTag:tLikeLike];
            break;
        }
        case tLikeDislike:
        {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:TRUE];
            [self.likeButton setTag:tLikeDislike];
            break;
        }
    }*/
    
    if (!self.watchLaterFetched && !self.watchLaterFetching) {
        self.watchLaterFetching = TRUE;
        [[APPVideoIsWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
         execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
         context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
         onStateChange:^(NSString *state, id data, NSError *error, id context) {
             if ([state isEqual:tFinished]) {
                 if (!error) {
                     if (data)
                         [self.watchLaterButton setSelected:YES];
                     self.watchLaterFetched = TRUE;
                     self.watchLaterFetching = FALSE;
                 } else {
                     self.watchLaterFetched = FALSE;
                     self.watchLaterFetching = FALSE;
                     [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                 message:[NSString stringWithFormat:@"Unable to check if video is a watch later. Please try again later."]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] show];
                 }
             }
         }];
    }
    
    
    if (!self.favoritesFetched && !self.favoritesFetching) {
        self.favoritesFetching = TRUE;
        [[APPVideoIsFavorite instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
         execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
         context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
         onStateChange:^(NSString *state, id data, NSError *error, id context) {
             if ([state isEqual:tFinished]) {
                 if (!error) {
                     if (data)
                         [self.favoritesButton setSelected:YES];
                     self.favoritesFetched = TRUE;
                     self.favoritesFetching = FALSE;
                 } else {
                     self.favoritesFetched = FALSE;
                     self.favoritesFetching = FALSE;
                     [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                 message:[NSString stringWithFormat:@"Unable to check if video is a favorite. Please try again later."]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] show];
                 }
             }
         }];
    }
}

#pragma mark - Managing the detail item
-(void)displayGoogleVideo:(NSString*)videoId
{
    NSString* embedHTML = [NSString stringWithFormat:@"<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId', {events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='320' height='%d' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&showinfo=0&controls=1&modestbranding=1&color=white&iv_load_policy=3&theme=light&autoplay=1' frameborder='0'></body></html>", heightVideoView, videoId];
    [self.webView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}

-(void)playVideo
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"ytplayer.playVideo()"];
}

-(BOOL)isVideoPlaying
{
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:@"ytplayer.getPlayerState()"];
    if ([result isEqualToString:@"1"] || [result isEqualToString:@"3"])
        return true;
    else
        return false;
}

-(void)pauseVideo
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"ytplayer.pauseVideo()"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController.viewControllers count] > 1)
        self.backButton.hidden = NO;
    else
        self.backButton.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSMutableDictionary *info = [NSMutableDictionary new];
    [info setValue:self.video forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:eventVideoWatched object:self userInfo:info];
}

-(void)back
{
    if ([self.navigationController.viewControllers count] > 1)
        [self popViewController];
}

-(void)subtopbarButtonPress:(UIButton*)sender
{
    switch (sender.tag)
    {
        case tLike:
        {
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeLike];
            [self.likeButton setSelected:TRUE];
            [APPQueryHelper likeVideo:self.video];
            break;
        }

        case tLikeLike:
        {
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeDislike];
            [self.likeButton setSelected:TRUE];
            [APPQueryHelper unlikeVideo:self.video];
            break;
        }

        case tLikeDislike:
        {
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeLike];
            [self.likeButton setSelected:TRUE];
            [APPQueryHelper likeVideo:self.video];
            break;
        }

        case tWatchLater:
        {
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            if (!self.watchLaterFetched) {
                if (!self.watchLaterFetching)
                    [self fetchState];
                [[[UIAlertView alloc] initWithTitle:@"Fetching state..."
                                            message:[NSString stringWithFormat:@"...if this video is a watch later."]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                return;
            }
            
            if ([self.watchLaterButton isSelected]) {
                [self.watchLaterButton setSelected:NO];
                
                NSMutableDictionary *info = [NSMutableDictionary new];
                [info setValue:video forKey:@"video"];
                [[NSNotificationCenter defaultCenter] postNotificationName:eventWillRemoveVideoFromWatchLater object:self userInfo:info];
                [APPQueryHelper removeVideoFromWatchLater:self.video];
            } else {
                [self.watchLaterButton setSelected:YES];
                
                NSMutableDictionary *info = [NSMutableDictionary new];
                [info setValue:video forKey:@"video"];
                [[NSNotificationCenter defaultCenter] postNotificationName:eventWillAddVideoToWatchLater object:self userInfo:info];
                [APPQueryHelper addVideoToWatchLater:self.video];
            }
            break;
        }

        case tFavorites:
        {
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            if (!self.favoritesFetched) {
                if (!self.favoritesFetching)
                    [self fetchState];
                [[[UIAlertView alloc] initWithTitle:@"Fetching state..."
                                            message:[NSString stringWithFormat:@"...if this video is a favorite."]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                return;
            }
            
            if ([self.favoritesButton isSelected]) {
                [self.favoritesButton setSelected:NO];
                
                NSMutableDictionary *info = [NSMutableDictionary new];
                [info setValue:self.video forKey:@"video"];
                [[NSNotificationCenter defaultCenter] postNotificationName:eventWillRemoveVideoFromFavorites object:self userInfo:info];
                [APPQueryHelper removeVideoFromFavorites:self.video];
            } else {
                [self.favoritesButton setSelected:YES];
                
                NSMutableDictionary *info = [NSMutableDictionary new];
                [info setValue:self.video forKey:@"video"];
                [[NSNotificationCenter defaultCenter] postNotificationName:eventWillAddVideoToFavorites object:self userInfo:info];
                [APPQueryHelper addVideoToFavorites:self.video];
            }
            break;
        }

        case tComments:
        {
            APPContentCommentListController *commentController = [[APPContentCommentListController alloc] initWithVideo:self.video];
            [self pushViewController:commentController];
            break;
        }

        case tAddToPlaylist:
        {
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            APPContentPlaylistListController *playlistController = [[APPContentPlaylistListController alloc] init];
            playlistController.afterSelect = ^(GDataEntryBase *entry) {
                [APPQueryHelper addVideo:self.video toPlaylist:(GDataEntryYouTubePlaylistLink*)entry];
            };
            [self pushViewController:playlistController];
            break;
        }
    }
}

-(void)subtopbarButtonPress2:(UIButton*)sender
{
    [self toState:[self keyToString:[NSNumber numberWithInt:[sender tag]]]];
}

// "APPTableViewDelegate" Protocol

-(void)beforeShowModeChange
{
    if ([self.tableView showMode] && [self.buttons objectForKey:[self.tableView showMode]])
        [[self.buttons objectForKey:[self.tableView showMode]] setSelected:NO];
}

-(void)afterShowModeChange
{
    if ([self.tableView showMode] && [self.buttons objectForKey:[self.tableView showMode]])
        [[self.buttons objectForKey:[self.tableView showMode]] setSelected:YES];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        if (oldContentOffset.y < newContentOffset.y && [self.tableViewHeaderFormView isHeaderShown] && newContentOffset.y > downAtTopDistance) {
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        } else if (oldContentOffset.y > newContentOffset.y && ![self.tableViewHeaderFormView isHeaderShown] && (downAtTopOnly ? (newContentOffset.y < downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - downAtTopDistance)))) {
            [self.tableViewHeaderFormView showOnCompletion:nil animated:NO];
        }

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(CGFloat)tableView:(UITableView*)tableView forMode:(NSString*)mode heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([mode isEqualToString:tRelatedVideosAll]) {
        return 88.0;
        
    } else {
        if (self.openCommentCell && [self.openCommentCell row] == [indexPath row]) {
            return self.rowOpenHeight;
        } else {
            return 88.0;
        }
    }
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([mode isEqualToString:self.relatedVideosId]) {
        APPVideoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
        if (cell == nil)
            cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];
        
        [cell setVideo:(GDataEntryYouTubeVideo*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]]];
        return cell;

    } else {
        APPCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPCommentCell"];
        if (cell == nil)
            cell = [[APPCommentCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPCommentCell"];

        [cell setComment:(GDataEntryYouTubeComment*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]]];
        if ([indexPath isEqual:self.openCommentCell])
            [cell setOpen:TRUE];
        return cell;
    }
}

-(int)tableView:(UITableView*)tableView forMode:(NSString*)mode numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataCache hasData:mode])
        return [[self.dataCache getData:mode] count];
    else
        return 0;
}

-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(NSString*)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState]) return nil;
    return indexPath;
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if ([self inState:tPassiveState]) return;
    
    if ([mode isEqualToString:self.relatedVideosId]) {
        GDataEntryYouTubeVideo *otherVideo = (GDataEntryYouTubeVideo*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
        APPContentVideoDetailViewController *videoController = [[APPContentVideoDetailViewController alloc] initWithVideo:otherVideo];
        [self pushViewController:videoController];
    
    } else {
        [self tapCell:indexPath];
    }
}

-(void)tapCell:(NSIndexPath*)indexPath;
{
    APPCommentCell *cell = (APPCommentCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.openCommentCell) {
        NSMutableArray *reloadArray = [NSMutableArray arrayWithObject:self.openCommentCell];
        NSIndexPath *tmp_row_open = self.openCommentCell;
        self.openCommentCell = nil;
        
        if ([tmp_row_open row] != [indexPath row]) {
            self.openCommentCell = indexPath;
            [reloadArray addObject:self.openCommentCell];
            self.rowOpenHeight = [cell cellHeightFullComment];
        }
        
        [self.tableView reloadRowsAtIndexPaths:reloadArray withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        self.openCommentCell = indexPath;
        self.rowOpenHeight = [cell cellHeightFullComment];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.openCommentCell] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return FALSE;
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
}

-(BOOL)tableView:(UITableView*)tableView canOpenCellforMode:(NSString*)mode forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
}

-(BOOL)hasData:(NSString*)key
{
    return [self.dataCache hasData:key];
}

-(BOOL)canLoadMoreData:(NSString*)key
{
    return [self.dataCache canLoadMoreData:key];
}

-(void)reloadData:(NSString*)key
{
    [self.dataCache reloadData:key withContext:self.tableView];
}

-(void)loadMoreData:(NSString*)key
{
    if ([self.dataCache canLoadMoreData:key])
        [self.dataCache loadMoreData:key withContext:self.tableView];
}

-(void)clearData:(NSString*)key
{
    [self.dataCache clearData:key];
}

-(void)dataReloadedFinished:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        [self.tableView dataReloadedFinished:key];
    }
}

-(void)dataReloadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    [self.dataCache clearData:key];
    if (self.tableView == tableView) {
        [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        [self.tableView dataReloadedError:key];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                    message:[NSString stringWithFormat:@"Unable to reload data. Please try again later."]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)dataMoreLoadedFinished:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        [self.tableView loadedMoreFinished:key];
    }
}

-(void)dataMoreLoadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification userInfo] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if (self.tableView == tableView) {
        [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        [self.tableView loadedMoreError:key];
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                    message:[NSString stringWithFormat:@"Unable to load more data. Please try again later."]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(BOOL)tableViewCanBottom:(UITableView*)view
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
}

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    if ([self inState:tPassiveState]) return FALSE;
    return TRUE;
}

-(void)processWillEvent:(NSNotification*)notification
{
    GDataEntryYouTubeVideo *tmpVideo = [(NSDictionary*)[notification userInfo] objectForKey:@"video"];
    if (tmpVideo != self.video)
        return;
    
    if ([[notification name] isEqualToString:eventWillAddVideoToFavorites]) {
        [self.favoritesButton setSelected:TRUE];
    } else if ([[notification name] isEqualToString:eventWillRemoveVideoFromFavorites]) {
        [self.favoritesButton setSelected:FALSE];
    } else if ([[notification name] isEqualToString:eventWillAddVideoToWatchLater]) {
        [self.watchLaterButton setSelected:TRUE];
    } else if ([[notification name] isEqualToString:eventWillRemoveVideoFromWatchLater]) {
        [self.watchLaterButton setSelected:FALSE];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    NSDictionary *context = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if ([context objectForKey:@"video"] != self.video)
        return;
    
    if ([[notification name] isEqualToString:eventAddedVideoToFavorites]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to favorites."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self reset];        
        }
        
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromFavorites]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove video from favorites."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self reset];
        }

    } else if ([[notification name] isEqualToString:eventAddedVideoToWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to watch later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self reset];
        }

    } else if ([[notification name] isEqualToString:eventRemovedVideoFromWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove video from watch later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self reset];
        }
    
    } else if ([[notification name] isEqualToString:eventVideoLiked]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to like video."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self reset];
        }
        
    } else if ([[notification name] isEqualToString:eventVideoUnliked]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to like video."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self reset];
        }
    }
}

-(NSNumber*)keyToNumber:(NSString*)key
{
    return [self.keyConvert objectForKey:key];
}

-(NSString*)keyToString:(NSNumber*)key
{
    NSArray *keys = [self.keyConvert allKeysForObject:key];
    if ([keys count] > 0) return keys[0];
    return NULL;
}

@end