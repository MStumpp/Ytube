//
//  APPVideoCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPVideoCell.h"
#import "APPQueryHelper.h"
#import "APPContent.h"
#import "APPVideoIsFavorite.h"
#import "APPVideoIsWatchLater.h"
#import "APPContentCommentListController.h"
#import "APPContentPlaylistListController.h"

@interface APPVideoCell ()
@property (strong, nonatomic) GDataEntryYouTubeVideo *video;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) int numberlikes;
@property (nonatomic) int numberdislikes;
@property (nonatomic) int views;
@property (nonatomic) int durationinseconds;

@property (strong, nonatomic) UIButton *addToPlaylistButton;
@property (strong, nonatomic) UIButton *watchLaterButton;
@property (strong, nonatomic) UIButton *favoritesButton;
@property (strong, nonatomic) UIButton *commentsButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *statisticsLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIImageView *thumbnailImage;
@property (strong, nonatomic) UIImageView *thumbnailImageFrame;
@property (strong, nonatomic) UIImageView *hdImage;
@property (strong, nonatomic) UIImageView *durationImage;
@property (strong, nonatomic) UIImageView *playImage;
@end

@implementation APPVideoCell
@synthesize title;
@synthesize subtitle;
@synthesize thumbnail;
@synthesize numberlikes;
@synthesize numberdislikes;
@synthesize views;
@synthesize durationinseconds;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initUI];
        [self prepareForReuse];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromWatchLater object:nil];
    }
    return self;
}

-(void)initUI
{
    self.addToPlaylistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addToPlaylistButton.frame = CGRectMake(10.0, 0, 77.0, 88.0);
    self.addToPlaylistButton.tag = tAddToPlaylist;
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_plus_up"] forState:UIControlStateNormal];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_plus_down"] forState:UIControlStateSelected];
    [self.addToPlaylistButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_plus_down"] forState:UIControlStateHighlighted];
    [self.tableCellSubMenu addSubview:self.addToPlaylistButton];
    
    self.watchLaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.watchLaterButton.frame = CGRectMake(87.0, 0, 77.0, 88.0);
    self.watchLaterButton.tag = tWatchLater;
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_clock_up"] forState:UIControlStateNormal];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_clock_down"] forState:UIControlStateSelected];
    [self.watchLaterButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_clock_down"] forState:UIControlStateHighlighted];
    [self.tableCellSubMenu addSubview:self.watchLaterButton];
    
    self.favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.favoritesButton.frame = CGRectMake(160.0, 0, 77.0, 88.0);
    self.favoritesButton.tag = tFavorites;
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_star_up"] forState:UIControlStateNormal];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_star_down"] forState:UIControlStateSelected];
    [self.favoritesButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_star_down"] forState:UIControlStateHighlighted];
    [self.tableCellSubMenu addSubview:self.favoritesButton];
    
    self.commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentsButton.frame = CGRectMake(228.0, 0, 77.0, 88.0);
    self.commentsButton.tag = tComments;
    [self.commentsButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_comment_up"] forState:UIControlStateNormal];
    [self.commentsButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_comment_down"] forState:UIControlStateSelected];
    [self.commentsButton setImage:[UIImage imageNamed:@"video_cell_menu_icon_comment_down"] forState:UIControlStateHighlighted];
    [self.tableCellSubMenu addSubview:self.commentsButton];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 170.0, 18.0)];
    [self.titleLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:13]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 39.0, 170.0, 13.0)];
    [self.subtitleLabel setFont:[UIFont fontWithName: @"Nexa Light" size:10]];
    [self.subtitleLabel setTextColor:[UIColor whiteColor]];
    [self.subtitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.subtitleLabel];
    
    self.statisticsLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 56.0, 170.0, 13.0)];
    [self.statisticsLabel setFont:[UIFont fontWithName:@"Nexa Light" size:10]];
    [self.statisticsLabel setTextColor:[UIColor whiteColor]];
    [self.statisticsLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.statisticsLabel];
        
    self.thumbnailImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 8.0, 105.0, 71.0)];
    [self.tableCellMain addSubview:self.thumbnailImage];
    
    self.thumbnailImageFrame = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 8.0, 105.0, 71.0)];
    [self.thumbnailImageFrame setImage:[UIImage imageNamed:@"video_cell_thumb_back"]];
    [self.tableCellMain addSubview:self.thumbnailImageFrame];
    
    self.hdImage = [[UIImageView alloc] initWithFrame:CGRectMake(22.0, 14.0, 17.0, 12.0)];
    [self.hdImage setImage:[UIImage imageNamed:@"video_cell_hd_logo"]];
    [self.tableCellMain addSubview:self.hdImage];
    [self setHD:FALSE];
    
    self.durationImage = [[UIImageView alloc] initWithFrame:CGRectMake(23.0, 61.0, 31.0, 13.0)];
    [self.durationImage setImage:[UIImage imageNamed:@"video_cell_dura_back"]];
    [self.tableCellMain addSubview:self.durationImage];
    
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.0, 63.0, 31.0, 11.0)];
    [self.durationLabel setFont:[UIFont fontWithName:@"Nexa Light" size:10]];
    [self.durationLabel setTextColor:[UIColor whiteColor]];
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];
    self.durationLabel.textAlignment = UITextAlignmentCenter;
    [self.tableCellMain addSubview:self.durationLabel];

    self.playImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 8.0, 105.0, 71.0)];
    [self.playImage setImage:[UIImage imageNamed:@"video_cell_play_arrow"]];
    [self.tableCellMain addSubview:self.playImage];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self allowToOpen:YES];
    [self.favoritesButton setSelected:NO];
    [self.watchLaterButton setSelected:NO];
    [self setThumbnail:[APPGlobals getGlobalForKey:@"noPreviewImage"]];
}

-(void)setTitle:(NSString*)n
{
    if (![n isEqualToString:title]) {
        title = [n copy];
        self.titleLabel.text = title;
    }
}

-(void)setSubtitle:(NSString*)n
{
    if (![n isEqualToString:subtitle]) {
        subtitle = [n copy];
        self.subtitleLabel.text = subtitle;
    }
}

-(void)setNumberlikes:(NSInteger)n
{
    if (!(n == numberlikes)) {
        numberlikes = n;
        [self updateStatisticsLabel];
    }
}

-(void)setNumberdislikes:(int)n
{
    if (!(n == numberdislikes)) {
        numberdislikes = n;
        [self updateStatisticsLabel];
    }
}

-(void)setViews:(int)n
{
    if (!(n == views)) {
        views = n;
        [self updateStatisticsLabel];
    }
}

-(void)updateStatisticsLabel
{
    self.statisticsLabel.text = [NSString stringWithFormat:@"%1.2f %%    %u views", ((float) numberlikes / (numberlikes + numberdislikes)) * 100.0, views];
}

-(void)setDurationinseconds:(int)n
{
    if (!(n == durationinseconds)) {
        durationinseconds = n;
        self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", durationinseconds/60, durationinseconds%60];
    }
}

-(void)setThumbnail:(UIImage*)n
{
    thumbnail = n;
    [self.thumbnailImage setImage:thumbnail];
}

-(void)setHD:(BOOL)n
{
    if (n == YES) {
        [self.hdImage setHidden:NO];
    } else {
        [self.hdImage setHidden:YES];
    }
}

-(void)setVideo:(GDataEntryYouTubeVideo*)video
{
    self.video = video;

    self.title = [[self.video title] stringValue];
    self.subtitle = [[self.video title] stringValue];

    self.numberlikes = [[[self.video rating] numberOfLikes] intValue];
    self.numberdislikes = [[[self.video rating] numberOfDislikes] intValue];
    self.views = [[[self.video statistics] viewCount] intValue];

    GDataYouTubeMediaGroup *mediaGroup = [self.video mediaGroup];
    self.durationinseconds = [[mediaGroup duration] intValue];

    [APPContent smallImageOfVideo:self.video callback:^(UIImage *image) {
        if (image) {
            self.thumbnail = image;
            [self setNeedsLayout];
        }
    }];

    // sub view set up

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
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesEnded:touches withEvent:event];
    if ([self isOpened]) {
        CGPoint location = [((UITouch *)[touches anyObject]) locationInView:self];
        if (CGRectContainsPoint(self.addToPlaylistButton.frame, location)) {
            APPContentPlaylistListController *select = [[APPContentPlaylistListController alloc] init];
            select.afterSelect = ^(GDataEntryYouTubePlaylistLink *playlist) {
                [APPQueryHelper addVideo:self.video toPlaylist:playlist];
            };
            [[self.tableView _delegate] pushViewController:select];

        } else if (CGRectContainsPoint(self.watchLaterButton.frame, location)) {
            if ([self.watchLaterButton isSelected]) {
                [self.watchLaterButton setSelected:NO];
                [APPQueryHelper removeVideoFromWatchLater:self.video];
            } else {
                [self.watchLaterButton setSelected:YES];
                [APPQueryHelper addVideoToWatchLater:self.video];
            }

        } else if (CGRectContainsPoint(self.favoritesButton.frame, location)) {
            if ([self.favoritesButton isSelected]) {
                [self.favoritesButton setSelected:NO];
                [APPQueryHelper removeVideoFromFavorites:self.video];
            } else {
                [self.favoritesButton setSelected:YES];
                [APPQueryHelper addVideoToFavorites:self.video];
            }

        } else if (CGRectContainsPoint(self.commentsButton.frame, location)) {
            APPContentCommentListController *select = [[APPContentCommentListController alloc] initWithVideo:self.video];
            [[self.tableView _delegate] pushViewController:select];
        }
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
    }
}

@end
