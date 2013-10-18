//
//  APPPlaylistCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPPlaylistCell.h"
#import "APPGlobals.h"
#import "APPContent.h"
#import <QuartzCore/QuartzCore.h>

@interface APPPlaylistCell ()
@property (nonatomic) GDataEntryYouTubePlaylistLink *playlist;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *numberVideos;
@property (nonatomic) NSString *description;
@property (nonatomic) UIImage *textPic;
@property UILabel *titleLabel;
@property UILabel *numberVideoLabel;
@property UILabel *descriptionLabel;
@property UIImageView *textPicImage;
@end

@implementation APPPlaylistCell
@synthesize playlist;
@synthesize title;
@synthesize numberVideos;
@synthesize description;
@synthesize textPic;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initUI];
        [self allowToOpen:NO];
        [self prepareForReuse];
    }
    return self;
}

-(void)initUI
{    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 170.0, 18.0)];
    [self.titleLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:13]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.titleLabel];
    
    self.numberVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 40.0, 170.0, 18.0)];
    [self.numberVideoLabel setFont:[UIFont fontWithName:@"Nexa Light" size:10]];
    [self.numberVideoLabel setTextColor:[UIColor whiteColor]];
    [self.numberVideoLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.numberVideoLabel];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 45.0, 170.0, 40.0)];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"Nexa Light" size:10]];
    [self.descriptionLabel setTextColor:[UIColor whiteColor]];
    [self.descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.descriptionLabel];
    
    self.textPicImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 8.0, 105.0, 71.0)];
    [self.tableCellMain addSubview:self.textPicImage];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self setTextPic:[[APPGlobals classInstance] getGlobalForKey:@"noPreviewImage"]];
}

-(void)setTitle:(NSString*)n
{
    if (![n isEqualToString:title]) {
        title = [n copy];
        self.titleLabel.text = title;
    }
}

-(void)setNumberVideos:(NSString*)n
{
    if (!(n == numberVideos)) {
        numberVideos = n;
        self.numberVideoLabel.text = [NSString stringWithFormat:@"%@ Videos", numberVideos];
    }
}

-(void)setDescription:(NSString*)n
{
    if (![n isEqualToString:description]) {
        description = [n copy];
        self.descriptionLabel.text = description;
    }
}

-(void)setTextPic:(UIImage*)n
{
    textPic = n;
    [self.textPicImage setImage:textPic];
    [self setNeedsLayout];
}

-(void)setPlaylist:(GDataEntryYouTubePlaylistLink*)p
{
    playlist = p;

    if ([self.playlist title])
        self.title = [[self.playlist title] stringValue];
    if ([self.playlist countHint])
        self.numberVideos = [self.playlist countHint];
    if ([self.playlist summary])
        self.description = [[self.playlist summary] stringValue];
    
    [APPContent smallImageOfPlaylist:self.playlist callback:^(UIImage *image) {
        if (image) {
            self.textPic = image;
            [self setNeedsLayout];
        }
    }];
}

@end

