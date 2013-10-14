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
@property UITableViewMaskView *likeButtonMask;
@property UIButton *watchLaterButton;
@property UITableViewMaskView *watchLaterButtonMask;
@property UIButton *favoritesButton;
@property UITableViewMaskView *favoritesButtonMask;
@property UIButton *commentButton;
@property UIButton *addToPlaylistButton;
@property UIButton *commentsButton;
@property UIButton *relatedVideosButton;
@property BOOL subtopbarWasVisible;
@end

@implementation APPContentVideoDetailViewController
@synthesize video;

-(id)initWithVideo:(GDataEntryYouTubeVideo*)v
{
    self = [self init];
    if (self) {
        self.video = v;
        self.topbarTitle = [[self.video title] stringValue];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self.dataCache clearData:tRelatedVideosAll];
        [self.dataCache clearData:tCommentsVideosAll];
        
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toDefaultShowMode];
        }];
        
        [[self configureState:tClearState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView clearViewAndReloadAll];
            [self refetchVideoState];
        }];
        
        self.subtopbarWasVisible = FALSE;
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // save state of header form
            if ([self.tableViewHeaderFormView isHeaderShown]) {
                [self setSubtopbarWasVisible:TRUE];
            } else {
                [self setSubtopbarWasVisible:FALSE];
            }
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        }];
        
        [[self configureState:tActiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // show header form if was visible
            if (self.subtopbarWasVisible) {
                [self.tableViewHeaderFormView showOnCompletion:nil animated:NO];
            }
        }];
        
        // configure tVideoDetailAll as default state
        [self setDefaultState:tRelatedVideosAll];
        
        [self.dataCache configureReloadDataForKey:tCommentsVideosAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            NSLog(@"onStateChange 1");
            queryHandler(key, [[APPVideoComments instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   NSLog(@"onStateChange 2");
                                   if ([state isEqual:tFinished]) {
                                       NSLog(@"onStateChange 3");
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        
        [self.dataCache configureReloadDataForKey:tRelatedVideosAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            NSLog(@"onStateChange 1");
            queryHandler(key, [[APPVideoRelatedVideos instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   NSLog(@"onStateChange 2");
                                   if ([state isEqual:tFinished]) {
                                       NSLog(@"onStateChange 3");
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [self.dataCache configureLoadMoreDataForKeys:@[tCommentsVideosAll, tRelatedVideosAll] withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToPlaylist object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromPlaylist object:nil];
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

    // set up video
    ////////////////
    UIImageView *videoThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, heightVideoView)];
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
    [self.view addSubview:videoPlayButton];
                
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, heightVideoView)];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.hidden = TRUE;
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
    self.likeButtonMask = [[UITableViewMaskView alloc] initWithRootView:self.likeButton customMaskView:nil delegate:self];
    [self.likeButtonMask maskOnCompletion:nil];
    [subtopbarContainer addSubview:self.likeButton];

    self.watchLaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.watchLaterButton.frame = CGRectMake(320.0-52.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.watchLaterButton setTag:tWatchLater];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_up"] forState:UIControlStateNormal];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateSelected];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateHighlighted];
    [self.watchLaterButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.watchLaterButton setSelected:NO];
    self.watchLaterButtonMask = [[UITableViewMaskView alloc] initWithRootView:self.watchLaterButton customMaskView:nil delegate:self];
    [self.watchLaterButtonMask maskOnCompletion:nil];
    [subtopbarContainer addSubview:self.watchLaterButton];
    
    self.favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoritesButton.frame = CGRectMake(320.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.favoritesButton setTag:tFavorites];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_up"] forState:UIControlStateNormal];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateSelected];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateHighlighted];
    [self.favoritesButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.favoritesButton setSelected:NO];
    self.favoritesButtonMask = [[UITableViewMaskView alloc] initWithRootView:self.favoritesButton customMaskView:nil delegate:self];
    [self.favoritesButtonMask maskOnCompletion:nil];
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
    
    [self refetchVideoState];

    // set up table
    ////////////////
    self.tableView = [[APPTableView alloc] initWithFrame:CGRectMake(0.0, heightVideoView+50.0+3.0, self.view.frame.size.width, self.view.frame.size.height-(heightVideoView+50.0+3.0)) style:UITableViewStylePlain];
    self.tableView._del = self;
    [self.view addSubview:self.tableView];
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];

    UIControl *subtopbarContainer2 = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer2 addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];
    
    self.commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 6.0, 132.0, 30.0)];
    [self.commentsButton addTarget:self action:@selector(subtopbarButtonPress2:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_up_2"] forState:UIControlStateNormal];
    [self.commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_down_2"] forState:UIControlStateHighlighted];
    [self.commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_down_2"] forState:UIControlStateSelected];
    [self.commentsButton setTag:tCommentsVideos];
    [subtopbarContainer2 addSubview:self.commentsButton];
    
    self.relatedVideosButton = [[UIButton alloc] initWithFrame:CGRectMake(172.0, 6.0, 132.0, 30.0)];
    [self.relatedVideosButton addTarget:self action:@selector(subtopbarButtonPress2:) forControlEvents:UIControlEventTouchUpInside];
    [self.relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_up_2"] forState:UIControlStateNormal];
    [self.relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_down_2"] forState:UIControlStateHighlighted];
    [self.relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_down_2"] forState:UIControlStateSelected];
    [self.relatedVideosButton setTag:tRelatedVideos];
    [subtopbarContainer2 addSubview:self.relatedVideosButton];
    
    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer2];
    
    [self.tableView addDefaultShowMode:tRelatedVideosAll];
    [self.tableView addShowMode:tCommentsVideosAll];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self displayGoogleVideo:[[self.video mediaGroup] videoID]];
    
    //NSArray *contents = [[(GDataEntryYouTubeVideo *) ytvideo mediaGroup] mediaContents];
    //GDataMediaContent *flashContent = [GDataUtilities firstObjectFromArray:contents withValue:@"application/x-shockwave-flash" forKeyPath:@"type"];
    //NSString *tempURL = [flashContent URLString];
}

-(void)refetchVideoState
{
    if ([self inState:tPassiveState]) return;
    if (![[APPUserManager classInstance] isUserSignedIn]) return;
    
    [self.likeButton setTag:tLike];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_up"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
    [self.likeButton setSelected:FALSE];
    [self.likeButtonMask maskOnCompletion:nil];
    
    switch ([APPContent likeStateOfVideo:self.video])
    {
        case tLikeLike:
        {
            [self.likeButton setSelected:TRUE];
            [self.likeButton setTag:tLikeLike];
            [self.likeButtonMask unmaskOnCompletion:nil];
            break;
        }
        case tLikeDislike:
        {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:TRUE];
            [self.likeButton setTag:tLikeDislike];
            [self.likeButtonMask unmaskOnCompletion:nil];
            break;
        }
        default:
        {
            [self.likeButtonMask unmaskOnCompletion:nil];
        }
    }
    
    [self.watchLaterButton setSelected:NO];
    [self.watchLaterButtonMask maskOnCompletion:nil];
    
    [[APPVideoIsWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
     execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
     context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
     onStateChange:^(NSString *state, id data, NSError *error, id context) {
         if ([state isEqual:tFinished]) {
             if (!error) {
                 if (data)
                     [self.watchLaterButton setSelected:YES];
                 [self.watchLaterButtonMask unmaskOnCompletion:nil];
             } else {
                 [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                             message:[NSString stringWithFormat:@"Unable to check if video is a watch later. Please try again later."]
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
         }
     }];
    
    [self.favoritesButton setSelected:NO];
    [self.favoritesButtonMask maskOnCompletion:nil];
    
    [[APPVideoIsFavorite instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
     execute:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
     context:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]
     onStateChange:^(NSString *state, id data, NSError *error, id context) {
         if ([state isEqual:tFinished]) {
             if (!error) {
                 if (data)
                     [self.favoritesButton setSelected:YES];
                 [self.favoritesButtonMask unmaskOnCompletion:nil];
             } else {
                 [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                             message:[NSString stringWithFormat:@"Unable to check if video is a favorite. Please try again later."]
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
         }
     }];
}

#pragma mark - Managing the detail item
-(void)displayGoogleVideo:(NSString*)videoId
{
    /*NSString *htmlString = [NSString stringWithFormat:@"<!DOCTYPE html><html><body><script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js\"></script><script type=\"text/javascript\">var tag = document.createElement('script');tag.src = \"http://www.youtube.com/iframe_api\";var firstScriptTag = document.getElementsByTagName('script')[0];firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);</script><script type=\"text/javascript\">var player;function onYouTubeIframeAPIReady() { $(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline', true); player = new YT.Player('player', {events: {'onReady': onPlayerReady}}); $(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline', true); } function onPlayerReady(event) { $(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline', true); $(\"#print\").html($(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline')); event.target.playVideo(); }</script><div id=\"print\"></div><iframe id=\"player\" type=\"text/html\" width=\"320\" height=\"175\" src=\"https://www.youtube.com/embed/%@?controls=0&enablejsapi=1&modestbranding=1&rel=0&showinfo=0&autohide=1\" frameborder=\"0\"></iframe></body></html>", videoId];*/
    /*NSString *htmlString = [NSString stringWithFormat:@"<html><head><link href=\"http://vjs.zencdn.net/c/video-js.css\" rel=\"stylesheet\"><script src=\"http://vjs.zencdn.net/c/video.js\"></script></head><body><video id=\"example_video_1\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" width=\"300\" height=\"150\" poster=\"http://video-js.zencoder.com/oceans-clip.png\" webkit-playsinline autoplay><source src=\"http://video-js.zencoder.com/oceans-clip.mp4\" type='video/mp4' /><source src=\"http://video-js.zencoder.com/oceans-clip.webm\" type='video/webm' /><source src=\"http://video-js.zencoder.com/oceans-clip.ogv\" type='video/ogg' /></video></body></html>"];*/
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><style>body,html,iframe{margin:0;padding:0;}</style><link href=\"https://dl.dropbox.com/u/1307305/video-js.css\" rel=\"stylesheet\" type=\"text/css\"><script src=\"https://dl.dropbox.com/u/1307305/video.js\"></script></head><body><video id=\"example_video_1\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" width=\"320\" height=\"175\" border=\"0\" webkit-playsinline autoplay data-setup='{\"techOrder\":[\"youtube\",\"html5\"]}'><source src=\"http://www.youtube.com/watch?v=%@\" type=\"video/youtube\"></video></body></html>", videoId];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    //[self.webView reload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController.viewControllers count] > 1)
        self.backButton.hidden = NO;
    else
        self.backButton.hidden = YES;
}

-(void)back
{
    if ([self.navigationController.viewControllers count] > 1)
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)subtopbarButtonPress:(UIButton*)sender
{
    switch (sender.tag)
    {
        case tLike:
        {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeLike];
            [APPQueryHelper likeVideo:self.video];
            break;
        }

        case tLikeLike:
        {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeDislike];
            [APPQueryHelper unlikeVideo:self.video];
            break;
        }

        case tLikeDislike:
        {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeLike];
            [APPQueryHelper likeVideo:self.video];
            break;
        }

        case tWatchLater:
        {
            if ([self.watchLaterButtonMask isMasked])
                return;
            
            if ([self.watchLaterButton isSelected]) {
                [self.watchLaterButton setSelected:NO];
                [APPQueryHelper removeVideoFromWatchLater:self.video];
            } else {
                [self.watchLaterButton setSelected:YES];
                [APPQueryHelper addVideoToWatchLater:self.video];
            }
            break;
        }

        case tFavorites:
        {
            if ([self.favoritesButtonMask isMasked])
                return;
            
            if ([self.favoritesButton isSelected]) {
                [self.favoritesButton setSelected:NO];
                [APPQueryHelper removeVideoFromFavorites:self.video];
            } else {
                [self.favoritesButton setSelected:YES];
                [APPQueryHelper addVideoToFavorites:self.video];
            }
            break;
        }

        case tComments:
        {
            APPContentCommentListController *select = [[APPContentCommentListController alloc] initWithVideo:self.video];
            [self.navigationController pushViewController:select animated:YES];
            break;
        }

        case tAddToPlaylist:
        {
            APPContentPlaylistListController *select = [[APPContentPlaylistListController alloc] init];
            [select undoDefaultMode:nil];
            select.afterSelect = ^(GDataEntryBase *entry) {
                [APPQueryHelper addVideo:self.video toPlaylist:(GDataEntryYouTubePlaylistLink*)entry];
            };
            [self.navigationController pushViewController:select animated:YES];
            break;
        }
    }
}

-(void)subtopbarButtonPress2:(UIButton*)sender
{
    if ([sender tag] == tCommentsVideos)
        [self.tableView toShowMode:tCommentsVideosAll];
    if ([sender tag] == tRelatedVideos)
        [self.tableView toShowMode:tRelatedVideosAll];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        if (oldContentOffset.y < newContentOffset.y && [self.tableViewHeaderFormView isHeaderShown] && newContentOffset.y > downAtTopDistance) {
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:YES];
        } else if (oldContentOffset.y > newContentOffset.y && ![self.tableViewHeaderFormView isHeaderShown] && (downAtTopOnly ? (newContentOffset.y < downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - downAtTopDistance)))) {
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([mode isEqualToString:tRelatedVideosAll]) {
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

    GDataEntryYouTubeVideo *otherVideo = (GDataEntryYouTubeVideo*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];

    if ([mode isEqualToString:tRelatedVideosAll]) {
        APPContentVideoDetailViewController *videoController = [[APPContentVideoDetailViewController alloc] initWithVideo:otherVideo];
        [videoController undoDefaultMode:nil];
        [self.navigationController pushViewController:videoController animated:YES];
    
    } else {
        APPContentCommentListController *commentController = [[APPContentCommentListController alloc] initWithVideo:otherVideo];
        [commentController undoDefaultMode:nil];
        [self.navigationController pushViewController:commentController animated:YES];
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
    if (![[APPUserManager classInstance] isUserSignedIn]) return FALSE;
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
    NSLog(@"reloadData %@", key);
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
    NSLog(@"dataReloadedFinished 1");
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        NSLog(@"dataReloadedFinished 2");
        [self.tableView dataReloadedFinished:key];
    }
}

-(void)dataReloadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    [self.dataCache clearData:key];
    if (self.tableView == tableView) {
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
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    if (self.tableView == tableView && [self.dataCache hasData:key]) {
        [self.tableView loadedMoreFinished:key];
    }
}

-(void)dataMoreLoadedError:(NSNotification*)notification
{
    NSString *key = [(NSDictionary*)[notification object] objectForKey:@"key"];
    UITableView *tableView = [(NSDictionary*)[notification object] objectForKey:@"context"];
    if (self.tableView == tableView) {
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

-(void)beforeShowModeChange
{
    return;
}

-(void)afterShowModeChange
{
    return;
}

-(void)pushViewController:(UIViewController*)controller
{
    if (!controller) return;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)processEvent:(NSNotification*)notification
{
    NSDictionary *context = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if ([context objectForKey:@"video"] != self.video)
        return;
    
    if ([[notification name] isEqualToString:eventAddedVideoToPlaylist]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to playlist."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromPlaylist]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to playlist."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        
    } else if ([[notification name] isEqualToString:eventAddedVideoToFavorites]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self reset];
        
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromFavorites]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self reset];
        
    } else if ([[notification name] isEqualToString:eventAddedVideoToWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self reset];
        
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self reset];
    
    } else if ([[notification name] isEqualToString:eventVideoLiked]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self reset];
        
    } else if ([[notification name] isEqualToString:eventVideoUnliked]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self reset];
    }
}

-(void)reset
{
    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                message:[NSString stringWithFormat:@"Unable to manage state of this video."]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
    [self refetchVideoState];
}

@end