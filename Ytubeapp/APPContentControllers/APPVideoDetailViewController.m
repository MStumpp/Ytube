//
//  APPVideoDetailViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.10.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPVideoDetailViewController.h"
#import "APPVideoLogicHelper.h"
#import "APPCommentLogicHelper.h"
#import "APPVideoCell.h"

@interface APPVideoDetailViewController ()
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UITableViewHeaderFormView *tableViewHeaderFormView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *watchLaterButton;
@property (strong, nonatomic) UIButton *favoritesButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *addToPlaylistButton;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *commentsButton;
@property (strong, nonatomic) UIButton *relatedVideosButton;
@property (retain, nonatomic) GDataFeedBase *feedComments;
@property (retain, nonatomic) GDataFeedBase *feedRelatedVideos;
@property (retain, nonatomic) NSMutableArray *customFeedComments;
@property (retain, nonatomic) NSMutableArray *customFeedRelatedVideos;
@property CGFloat heightVideoView;
@property BOOL downAtTopOnly;
@property int downAtTopDistance;
@end

@implementation APPVideoDetailViewController

@synthesize video;

- (id)init
{
    self = [super init];
    if (self) {        
        self.heightVideoView = 186.0;
        // header form stuff
        self.downAtTopOnly = TRUE;
        self.downAtTopDistance = 40;
        
        id this = self;
        [[[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.feedComments = nil;
            self.feedRelatedVideos = nil;
            self.customFeedComments = nil;
            self.customFeedRelatedVideos = nil;
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tComments];
        }] onViewState:tDidAppear do:^{
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:YES];
            //[self.tableView scrollsToTop];
        }];
        
        [self toInitialState];
    }
    return self;
}

- (id)initWithVideo:(GDataEntryYouTubeVideo *)vid
{
    self = [self init];
    if (self) {
        self.video = vid;
        self.topbarTitle = [[self.video title] stringValue];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
        
    UIImageView *videoThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.heightVideoView)];
    videoThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    videoThumbnail.clipsToBounds = YES;
    [self.contentManager imageLargeForVideo:self.video callback:^(UIImage *image) {
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

    // Set up button bar
    
    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, self.heightVideoView, self.view.frame.size.width, 50.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_detail_nav"]]];
    [self.view addSubview:subtopbarContainer];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0.0, 0.0, 52.0, 50.0);
    [self.backButton setImage:[UIImage imageNamed:@"video_detail_arrow_left_up"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"video_detail_arrow_left_down"] forState:UIControlStateSelected];
    [self.backButton setImage:[UIImage imageNamed:@"video_detail_arrow_left_down"] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.backButton];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.frame = CGRectMake(320.0-52.0-52.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    self.likeButton.tag = tLike;
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_up"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
    [self.likeButton setSelected:FALSE];    
    [self.likeButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.likeButton];
    [self.contentManager likeStateOfVideo:self.video callback:^(NSInteger state) {
        if (state == tLikeLike) {
            [self.likeButton setSelected:TRUE];
            [self.likeButton setTag:tLikeLike];
        }
        if (state == tLikeDislike) {
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
            [self.likeButton setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
            [self.likeButton setSelected:TRUE];
            [self.likeButton setTag:tLikeDislike];
        }
    }];
    
    self.watchLaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.watchLaterButton.frame = CGRectMake(320.0-52.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    self.watchLaterButton.tag = tWatchLater;
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_up"] forState:UIControlStateNormal];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateSelected];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_detail_clock_down"] forState:UIControlStateHighlighted];
    [self.watchLaterButton setSelected:FALSE];
    [self.watchLaterButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.watchLaterButton];
    [self.contentManager isVideoWatchLater:self.video callback:^(GDataEntryYouTubeVideo *tmp_video, NSError *error) {
        if (tmp_video && !error)
            [self.watchLaterButton setSelected:TRUE];
    }];

    self.favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoritesButton.frame = CGRectMake(320.0-52.0-52.0-52.0, 0.0, 52.0, 50.0);
    self.favoritesButton.tag = tFavorites;
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_up"] forState:UIControlStateNormal];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateSelected];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_detail_star_down"] forState:UIControlStateHighlighted];
    [self.favoritesButton setSelected:FALSE];
    [self.favoritesButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.favoritesButton];
    [self.contentManager isVideoFavorite:self.video callback:^(GDataEntryYouTubeFavorite *tmp_video, NSError *error) {
        if (tmp_video && !error)
            [self.favoritesButton setSelected:TRUE];
    }];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.frame = CGRectMake(320.0-52.0-52.0, 0.0, 52.0, 50.0);
    self.commentButton.tag = tComments;
    [self.commentButton setImage:[UIImage imageNamed:@"video_detail_comment_up"] forState:UIControlStateNormal];
    [self.commentButton setImage:[UIImage imageNamed:@"video_detail_comment_down"] forState:UIControlStateSelected];
    [self.commentButton setImage:[UIImage imageNamed:@"video_detail_comment_down"] forState:UIControlStateHighlighted];
    [self.commentButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.commentButton];
    
    self.addToPlaylistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addToPlaylistButton.frame = CGRectMake(320.0-52.0, 0.0, 52.0, 50.0);
    self.addToPlaylistButton.tag = tAddToPlaylist;
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_detail_plus_up"] forState:UIControlStateNormal];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_detail_plus_down"] forState:UIControlStateSelected];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_detail_plus_down"] forState:UIControlStateHighlighted];
    [self.addToPlaylistButton addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [subtopbarContainer addSubview:self.addToPlaylistButton];
    
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
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    self.buttons = [[NSDictionary alloc] initWithObjectsAndKeys:
                    self.commentsButton, [NSNumber numberWithInt:tComments],
                    self.relatedVideosButton, [NSNumber numberWithInt:tRelatedVideos],
                    nil];
    
    [self displayGoogleVideo:[[self.video mediaGroup] videoID]];
    
    //NSArray *contents = [[(GDataEntryYouTubeVideo *) ytvideo mediaGroup] mediaContents];
    //GDataMediaContent *flashContent = [GDataUtilities firstObjectFromArray:contents withValue:@"application/x-shockwave-flash" forKeyPath:@"type"];
    //NSString *tempURL = [flashContent URLString];
}

#pragma mark - Managing the detail item
- (void) displayGoogleVideo:(NSString *)videoId
{
    /*NSString *htmlString = [NSString stringWithFormat:@"<!DOCTYPE html><html><body><script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js\"></script><script type=\"text/javascript\">var tag = document.createElement('script');tag.src = \"http://www.youtube.com/iframe_api\";var firstScriptTag = document.getElementsByTagName('script')[0];firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);</script><script type=\"text/javascript\">var player;function onYouTubeIframeAPIReady() { $(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline', true); player = new YT.Player('player', {events: {'onReady': onPlayerReady}}); $(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline', true); } function onPlayerReady(event) { $(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline', true); $(\"#print\").html($(\"#player\").contents().find(\"video.video-stream\").attr('webkit-playsinline')); event.target.playVideo(); }</script><div id=\"print\"></div><iframe id=\"player\" type=\"text/html\" width=\"320\" height=\"175\" src=\"https://www.youtube.com/embed/%@?controls=0&enablejsapi=1&modestbranding=1&rel=0&showinfo=0&autohide=1\" frameborder=\"0\"></iframe></body></html>", videoId];*/
    
    /*NSString *htmlString = [NSString stringWithFormat:@"<html><head><link href=\"http://vjs.zencdn.net/c/video-js.css\" rel=\"stylesheet\"><script src=\"http://vjs.zencdn.net/c/video.js\"></script></head><body><video id=\"example_video_1\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" width=\"300\" height=\"150\" poster=\"http://video-js.zencoder.com/oceans-clip.png\" webkit-playsinline autoplay><source src=\"http://video-js.zencoder.com/oceans-clip.mp4\" type='video/mp4' /><source src=\"http://video-js.zencoder.com/oceans-clip.webm\" type='video/webm' /><source src=\"http://video-js.zencoder.com/oceans-clip.ogv\" type='video/ogg' /></video></body></html>"];*/
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><style>body,html,iframe{margin:0;padding:0;}</style><link href=\"https://dl.dropbox.com/u/1307305/video-js.css\" rel=\"stylesheet\" type=\"text/css\"><script src=\"https://dl.dropbox.com/u/1307305/video.js\"></script></head><body><video id=\"example_video_1\" class=\"video-js vjs-default-skin\" controls preload=\"auto\" width=\"320\" height=\"175\" border=\"0\" webkit-playsinline autoplay data-setup='{\"techOrder\":[\"youtube\",\"html5\"]}'><source src=\"http://www.youtube.com/watch?v=%@\" type=\"video/youtube\"></video></body></html>", videoId];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
    //[self.webView reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Should move to some class containing navigation bar specific code
    if ([self.navigationController.viewControllers count] > 1)
        self.backButton.hidden = NO;
    else
        self.backButton.hidden = YES;
}

// Should move to some class containing navigation bar specific code

- (void)back
{
    if ([self.navigationController.viewControllers count] > 1)
        [(TVNavigationController*)self.navigationController popViewControllerOnCompletion:nil context:nil animated:YES];
}

- (void)subtopbarButtonPress:(UIButton*)sender
{
    [APPVideoLogicHelper videoAction:self.video button:sender delegate:self];
}

- (void)subtopbarButtonPress2:(UIButton*)sender
{
    if ([sender tag] != self.showMode)
        [self toShowMode:[sender tag]];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
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

- (void)reloadData
{
    if (self.showMode == tRelatedVideos) {
        [self.contentManager relatedVideos:self.video delegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
        
    } else if (self.showMode == tComments) {
        [self.contentManager comments:self.video delegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
    }
}

- (void)loadMoreData
{
    if ([self currentFeed])
        [self.contentManager loadMoreData:[self currentFeed] delegate:self didFinishSelector:@selector(loadMoreDataResponse:finishedWithFeed:error:)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showMode == tRelatedVideos)
        return [APPVideoLogicHelper tableView:tableView cellForRowAtIndexPath:indexPath delegate:self];
    else
        return [APPCommentLogicHelper tableView:tableView cellForRowAtIndexPath:indexPath delegate:self];
}

- (void)tableViewCellButtonTouched:(APPTableCell *)cell button:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{
    if (self.showMode == tRelatedVideos) {
        GDataEntryYouTubeVideo *vid = (GDataEntryYouTubeVideo *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
        [APPVideoLogicHelper videoAction:vid button:button delegate:self];
    }
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showMode == tRelatedVideos) {
        APPVideoCell *selectedCell = (APPVideoCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        if (![selectedCell isOpened])
            return indexPath;
        else
            return nil;
        
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showMode == tRelatedVideos) {
        APPVideoDetailViewController *detailController = [[APPVideoDetailViewController alloc] initWithVideo:[[self currentCustomFeed] objectAtIndex:[indexPath row]]];
        [(TVNavigationController*)self.navigationController pushViewController:detailController onCompletion:nil context:nil animated:YES];
    }
}

- (GDataFeedBase*)currentFeed:(GDataFeedBase*)feed
{
    switch (self.showMode)
    {
        case tRelatedVideos:
            if (feed)
                self.feedRelatedVideos = feed;
            return self.feedRelatedVideos;
        case tComments:
            if (feed)
                self.feedComments = feed;
            return self.feedComments;
        default:
            return nil;
    }
}

- (NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed;
{
    switch (self.showMode)
    {
        case tRelatedVideos:
            if (feed)
                self.customFeedRelatedVideos = feed;
            return self.customFeedRelatedVideos;
        case tComments:
            if (feed)
                self.customFeedComments = feed;
            return self.customFeedComments;
        default:
            return nil;
    }
}

@end
