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

@interface APPContentVideoDetailViewController ()
@property UIWebView *webView;
@property APPTableView *tableView;
@property UITableViewHeaderFormView *tableViewHeaderFormView;
@property UIButton *backButton;
@property UIButton *likeButton;
@property UIButton *watchLaterButton;
@property UIButton *favoritesButton;
@property UIButton *commentButton;
@property UIButton *addToPlaylistButton;
@property UIButton *commentsButton;
@property UIButton *relatedVideosButton;
@property CGFloat heightVideoView;
@property BOOL downAtTopOnly;
@property int downAtTopDistance;
@end

@implementation APPContentVideoDetailViewController

-(id)init
{
    self = [super init];
    if (self) {
        [self.tableView addDefaultShowMode:tComments];
        [self.tableView addShowMode:tRelatedVideos];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventVideoLiked object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventVideoUnliked object:nil];

        [[self configureDefaultState] onViewState:tDidLoadViewState do:^{
            // reloads table view content
            [self.tableView clearViewAndReloadAll];
            [self.tableView toDefaultShowMode];
        }];
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^{
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:YES];
            [self.tableView scrollsToTop];
        }];
        [self toDefaultStateForce];
    }
    return self;
}

-(id)initWithVideo:(GDataEntryYouTubeVideo*)video
{
    self = [self init];
    if (self) {
        self.video = video;
        self.topbarTitle = [[self.video title] stringValue];
    }
    return self;
}

-(void)loadView
{
    [super loadView];

    // set up video
    UIImageView *videoThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.heightVideoView)];
    videoThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    videoThumbnail.clipsToBounds = YES;

    [APPContent largeImageOfVideo:self.video callback:^(UIImage *image) {
        if (image)
            [videoThumbnail setImage:image];
    }];
    [self.view addSubview:videoThumbnail];
    
    // add play button on top of preview thumbnail
    UIImageView *videoPlayButton = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.heightVideoView)];
    [videoPlayButton setImage:[UIImage imageNamed:@"video_detail_back"]];
    [self.view addSubview:videoPlayButton];
                
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.heightVideoView)];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.hidden = TRUE;
    [self.view addSubview:self.webView];

    // set up button bar
    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, self.heightVideoView, self.view.frame.size.width, 50.0)];
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
    switch ([APPContent likeStateOfVideo:self.video])
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
    }

    self.watchLaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.watchLaterButton.frame = CGRectMake(320.0-52.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.watchLaterButton setTag:tWatchLater];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_up"] forState:UIControlStateNormal];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateSelected];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateHighlighted];
    [self.watchLaterButton setSelected:FALSE];
    [self.watchLaterButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.watchLaterButton];

    [[APPVideoIsWatchLater instanceWithQueue:[[APPGlobals getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
      onStateChange:^(Query *query, id data) {
          if ([query isFinished]) {
              if (![query isCancelled] && ![(APPAbstractQuery*)query hasError]) {
                  if([(NSDictionary*)data objectForKey:@"playlist"])
                      [self.watchLaterButton setSelected:YES];
              } else {
                  NSLog(@"APPVideoIsWatchLater: error");
              }
          }
      }];

    self.favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoritesButton.frame = CGRectMake(320.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    [self.favoritesButton setTag:tFavorites];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_up"] forState:UIControlStateNormal];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateSelected];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateHighlighted];
    [self.favoritesButton setSelected:FALSE];
    [self.favoritesButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.favoritesButton];

    [[APPVideoIsFavorite instanceWithQueue:[[APPGlobals getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
      onStateChange:^(Query *query, id data) {
          if ([query isFinished]) {
              if (![query isCancelled] && ![(APPAbstractQuery*)query hasError]) {
                  if([(NSDictionary*)data objectForKey:@"favorite"])
                      [self.favoritesButton setSelected:YES];
              } else {
                  NSLog(@"APPVideoIsFavorite: error");
              }
          }
      }];

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

    // set up table
    self.tableView.frame = CGRectMake(0.0, self.heightVideoView+50.0+3.0, self.view.frame.size.width, self.view.frame.size.height-(self.heightVideoView+50.0+3.0));
    self.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:self.tableView headerView:nil delegate:self];

    UIControl *subtopbarContainer2 = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer2 addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];
    
    self.commentsButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 6.0, 132.0, 30.0)];
    [self.commentsButton addTarget:self action:@selector(subtopbarButtonPress2:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_up_2"] forState:UIControlStateNormal];
    [self.commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_down_2"] forState:UIControlStateHighlighted];
    [self.commentsButton setImage:[UIImage imageNamed:@"sub_top_bar_button_comments_down_2"] forState:UIControlStateSelected];
    [self.commentsButton setTag:tComments];
    [subtopbarContainer2 addSubview:self.commentsButton];
    
    self.relatedVideosButton = [[UIButton alloc] initWithFrame:CGRectMake(172.0, 6.0, 132.0, 30.0)];
    [self.relatedVideosButton addTarget:self action:@selector(subtopbarButtonPress2:) forControlEvents:UIControlEventTouchUpInside];
    [self.relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_up_2"] forState:UIControlStateNormal];
    [self.relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_down_2"] forState:UIControlStateHighlighted];
    [self.relatedVideosButton setImage:[UIImage imageNamed:@"sub_top_bar_button_related_videos_down_2"] forState:UIControlStateSelected];
    [self.relatedVideosButton setTag:tRelatedVideos];
    [subtopbarContainer2 addSubview:self.relatedVideosButton];
    
    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer2];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    [self displayGoogleVideo:[[self.video mediaGroup] videoID]];
    
    //NSArray *contents = [[(GDataEntryYouTubeVideo *) ytvideo mediaGroup] mediaContents];
    //GDataMediaContent *flashContent = [GDataUtilities firstObjectFromArray:contents withValue:@"application/x-shockwave-flash" forKeyPath:@"type"];
    //NSString *tempURL = [flashContent URLString];
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

// Should move to some class containing navigation bar specific code

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
    [self.tableView toShowMode:[sender tag]];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        if (oldContentOffset.y < newContentOffset.y && [self.tableViewHeaderFormView isHeaderShown] && newContentOffset.y > self.downAtTopDistance) {
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:YES];
        } else if (oldContentOffset.y > newContentOffset.y && ![self.tableViewHeaderFormView isHeaderShown] && (self.downAtTopOnly ? (newContentOffset.y < self.downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - self.downAtTopDistance)))) {
            [self.tableViewHeaderFormView showOnCompletion:nil animated:YES];
        }

        //if((newVal.y >= 0.0) && (newVal.y <= self.tableView.contentSize.height)) {
        //}

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    if (mode == tRelatedVideos)
        return [APPQueryHelper relatedVideos:self.video showMode:mode withPrio:p delegate:tableView];
    else if (mode == tComments)
        return [APPQueryHelper videoComments:self.video showMode:mode withPrio:p delegate:tableView];
}

-(Query*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)p
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:p delegate:tableView];
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(int)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (mode == tRelatedVideos) {
        APPVideoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
        if (cell == nil)
            cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];

        [cell setVideo:(GDataEntryYouTubeVideo*)[[self.tableView currentCustomFeedForShowMode:mode] objectAtIndex:[indexPath row]]];
        return cell;

    } else if (mode == tComments) {
        APPCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPCommentCell"];
        if (cell == nil)
            cell = [[APPCommentCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPCommentCell"];

        [cell setComment:(GDataEntryYouTubeComment*)[[self.tableView currentCustomFeedForShowMode:mode] objectAtIndex:[indexPath row]]];
        return cell;
    }
}

-(void)tableView:(UITableView*)tableView forMode:(int)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.isDefaultMode)
        return;

    if (mode == tRelatedVideos) {

        GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo*)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];

        if (self.afterSelect) {
            [self.navigationController popViewControllerAnimated:YES];
            self.afterSelect(video);
        } else {
            [self.navigationController pushViewController:[[APPContentVideoDetailViewController alloc] initWithVideo:video] animated:YES];
        }

    } else if (mode == tComments) {
        NSLog(@"not yet implemented");
    }
}

-(void)processEvent:(NSNotification*)notification
{
    if (![[(NSDictionary*)[notification object] objectForKey:@"video"] isEqual:self.video])
        return;

    if ([[notification name] isEqualToString:eventAddedVideoToFavorites]) {
        if ([(NSDictionary*)[notification object] objectForKey:@"error"])
            [self.favoritesButton setSelected:NO];

    } else if ([[notification name] isEqualToString:eventRemovedVideoFromFavorites]) {
        if ([(NSDictionary*)[notification object] objectForKey:@"error"])
            [self.favoritesButton setSelected:YES];

    } else if ([[notification name] isEqualToString:eventAddedVideoToWatchLater]) {
        if ([(NSDictionary*)[notification object] objectForKey:@"error"])
            [self.watchLaterButton setSelected:NO];

    } else if ([[notification name] isEqualToString:eventRemovedVideoFromWatchLater]) {
        if ([(NSDictionary*)[notification object] objectForKey:@"error"])
            [self.watchLaterButton setSelected:YES];

    } else if ([[notification name] isEqualToString:eventVideoLiked]) {
        if ([(NSDictionary*)[notification object] objectForKey:@"error"]) {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeDislike];
        }

    } else if ([[notification name] isEqualToString:eventVideoUnliked]) {
        if ([(NSDictionary*)[notification object] objectForKey:@"error"]) {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
            [self.likeButton setTag:tLikeLike];
        }
    }
}

@end