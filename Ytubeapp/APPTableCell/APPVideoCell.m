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
@property (nonatomic) GDataEntryYouTubeVideo *video;
@property UITableViewMaskView *tableViewMaskView;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) int numberlikes;
@property (nonatomic) int numberdislikes;
@property (nonatomic) int views;
@property (nonatomic) int durationinseconds;
@property UIButton *addToPlaylistButton;
@property UIButton *watchLaterButton;
@property UIButton *favoritesButton;
@property UIButton *commentsButton;
@property UILabel *titleLabel;
@property UILabel *subtitleLabel;
@property UILabel *statisticsLabel;
@property UILabel *durationLabel;
@property UIImageView *thumbnailImage;
@property UIImageView *thumbnailImageFrame;
@property UIImageView *hdImage;
@property UIImageView *durationImage;
@property UIImageView *playImage;
@property BOOL favoritesFetching;
@property BOOL watchLaterFetching;
@property BOOL favoritesFetched;
@property BOOL watchLaterFetched;
@end

@implementation APPVideoCell
@synthesize title;
@synthesize subtitle;
@synthesize thumbnail;
@synthesize numberlikes;
@synthesize numberdislikes;
@synthesize views;
@synthesize durationinseconds;
@synthesize video;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initUI];
        [self allowToOpen:YES];
        [self reset];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedIn:) name:eventUserSignedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedOut:) name:eventUserSignedOut object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillAddVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillRemoveVideoFromFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillAddVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWillEvent:) name:eventWillRemoveVideoFromWatchLater object:nil];
        
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
    self.commentsButton.frame = CGRectMake(232.0, 0, 77.0, 88.0);
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
    [self setThumbnail:[[APPGlobals classInstance] getGlobalForKey:@"noPreviewImage"]];
    [self reset];
}

-(void)reset
{
    self.favoritesFetching = FALSE;
    self.watchLaterFetching = FALSE;
    self.favoritesFetched = FALSE;
    self.watchLaterFetched = FALSE;
    [self.favoritesButton setSelected:NO];
    [self.watchLaterButton setSelected:NO];
    if ([self isOpened])
        [self fetchState];
}

-(void)cellDidOpen
{
    [self fetchState];
}

-(void)fetchState
{
    if (![[APPUserManager classInstance] isUserSignedIn])
        return;
    
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

-(void)setVideo:(GDataEntryYouTubeVideo*)v
{
    video = v;

    if ([self.video respondsToSelector:@selector(title)] && [[self.video title] stringValue])
        self.title = [[self.video title] stringValue];
    if ([self.video respondsToSelector:@selector(title)] && [[self.video title] stringValue])
        self.subtitle = [[self.video title] stringValue];
    if ([self.video respondsToSelector:@selector(rating)] && [[self.video rating] numberOfLikes])
        self.numberlikes = [[[self.video rating] numberOfLikes] intValue];
    if ([self.video respondsToSelector:@selector(rating)] && [[self.video rating] numberOfDislikes])
        self.numberdislikes = [[[self.video rating] numberOfDislikes] intValue];
    if ([self.video respondsToSelector:@selector(statistics)] && [[self.video statistics] viewCount])
        self.views = [[[self.video statistics] viewCount] intValue];
    if ([self.video respondsToSelector:@selector(mediaGroup)]) {
        GDataYouTubeMediaGroup *mediaGroup = [self.video mediaGroup];
        self.durationinseconds = [[mediaGroup duration] intValue];
    }

    [APPContent smallImageOfVideo:self.video callback:^(UIImage *image) {
        if (image) {
            self.thumbnail = image;
            [self setNeedsLayout];
        }
    }];
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesEnded:touches withEvent:event];
    
    if ([self.tableViewMaskView isMasked])
        return;
    
    if ([self isOpened]) {
        CGPoint location = [((UITouch *)[touches anyObject]) locationInView:self];
        if (CGRectContainsPoint(self.addToPlaylistButton.frame, location)) {
            
            if (![[APPUserManager classInstance] isUserSignedIn]) {
                [self showSignAlert];
                return;
            }
            
            APPContentPlaylistListController *playlistController = [[APPContentPlaylistListController alloc] init];
            playlistController.afterSelect = ^(GDataEntryBase *entry) {
                [APPQueryHelper addVideo:self.video toPlaylist:(GDataEntryYouTubePlaylistLink*)entry];
            };
            [[self.__tableView _del] pushViewController:playlistController];

        } else if (CGRectContainsPoint(self.watchLaterButton.frame, location)) {
            
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

        } else if (CGRectContainsPoint(self.favoritesButton.frame, location)) {
            
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

        } else if (CGRectContainsPoint(self.commentsButton.frame, location)) {
            APPContentCommentListController *commentController = [[APPContentCommentListController alloc] initWithVideo:self.video];
            [[self.__tableView _del] pushViewController:commentController];
        }
    }
}

-(void)processWillEvent:(NSNotification*)notification
{
    GDataEntryYouTubeVideo *tmpVideo = [(NSDictionary*)[notification userInfo] objectForKey:@"video"];
    if (![[APPContent videoID:tmpVideo] isEqualToString:[APPContent videoID:self.video]])
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
    }
}

-(void)userSignedIn:(NSNotification*)notification
{
    [self reset];
}

-(void)userSignedOut:(NSNotification*)notification
{
    [self reset];
}

-(void)showSignAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Please sign in..."
                                message:[NSString stringWithFormat:@"...to use this function."]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
