//
//  APPVideoCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPVideoCell.h"
#import <QuartzCore/QuartzCore.h>

@interface APPVideoCell ()

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

@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize statisticsLabel;
@synthesize durationLabel;
@synthesize thumbnailImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        [self allowToOpen:YES];
        [self.favoritesButton setSelected:NO];
        [self.watchLaterButton setSelected:NO];
        [self setThumbnail:[[ViewHelpers classInstance] noPreviewImage]];
    }
    return self;
}

- (void)initUI
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self allowToOpen:YES];
    [self.favoritesButton setSelected:NO];
    [self.watchLaterButton setSelected:NO];
    [self setThumbnail:[[ViewHelpers classInstance] noPreviewImage]];
}

- (void)setTitle:(NSString *)n {
    if (![n isEqualToString:title]) {
        title = [n copy];
        titleLabel.text = title;
    }
}

- (void)setSubtitle:(NSString *)n {
    if (![n isEqualToString:subtitle]) {
        subtitle = [n copy];
        subtitleLabel.text = subtitle;
    }
}

- (void)setNumberlikes:(NSInteger)n {
    if (!(n == numberlikes)) {
        numberlikes = n;
        [self updateStatisticsLabel];
    }
}

- (void)setNumberdislikes:(int)n {
    if (!(n == numberdislikes)) {
        numberdislikes = n;
        [self updateStatisticsLabel];
    }
}

- (void)setViews:(int)n {
    if (!(n == views)) {
        views = n;
        [self updateStatisticsLabel];
    }
}

- (void)updateStatisticsLabel
{
    statisticsLabel.text = [NSString stringWithFormat:@"%1.2f %%    %u views", ((float) numberlikes / (numberlikes + numberdislikes)) * 100.0, views];
}

- (void)setDurationinseconds:(int)n {
    if (!(n == durationinseconds)) {
        durationinseconds = n;
        durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", durationinseconds/60, durationinseconds%60];
    }
}

- (void)setThumbnail:(UIImage *)n {
    thumbnail = n;
    [thumbnailImage setImage:thumbnail];
}

- (void)setHD:(BOOL)n
{
    if (n == YES) {
        [self.hdImage setHidden:NO];
    } else {
        [self.hdImage setHidden:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self isOpened]) {
        CGPoint location = [((UITouch *)[touches anyObject]) locationInView:self];
        if (CGRectContainsPoint(self.addToPlaylistButton.frame, location))
            [self.touchButtonDelegate tableViewCellButtonTouched:self button:(UIButton*)self.addToPlaylistButton indexPath:self.touchButtonIndexPath];
        if (CGRectContainsPoint(self.watchLaterButton.frame, location))
            [self.touchButtonDelegate tableViewCellButtonTouched:self button:(UIButton*)self.watchLaterButton indexPath:self.touchButtonIndexPath];
        if (CGRectContainsPoint(self.favoritesButton.frame, location))
            [self.touchButtonDelegate tableViewCellButtonTouched:self button:(UIButton*)self.favoritesButton indexPath:self.touchButtonIndexPath];
        if (CGRectContainsPoint(self.commentsButton.frame, location))
            [self.touchButtonDelegate tableViewCellButtonTouched:self button:(UIButton*)self.commentsButton indexPath:self.touchButtonIndexPath];    
    }
}

@end
