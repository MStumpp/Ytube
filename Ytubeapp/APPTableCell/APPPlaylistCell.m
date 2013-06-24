//
//  APPPlaylistCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPPlaylistCell.h"
#import "APPGlobals.h"
#import "APPPlaylistImageOfPlaylist.h"
#import <QuartzCore/QuartzCore.h>

@interface APPPlaylistCell ()
@property (strong, nonatomic) GDataEntryYouTubePlaylistLink *playlist;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) UIImage *textPic;
@property (nonatomic) int numberItems;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIImageView *textPicImage;
@end

@implementation APPPlaylistCell
@synthesize text;
@synthesize description;
@synthesize textPic;
@synthesize numberItems;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initUI];
        [self prepareForReuse];
    }
    return self;
}

-(void)initUI
{    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 170.0, 18.0)];
    [self.textLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:13]];
    [self.textLabel setTextColor:[UIColor whiteColor]];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.textLabel];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 30.0, 170.0, 40.0)];
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
    [self allowToOpen:NO];
    [self setTextPic:[APPGlobals getGlobalForKey:@"noPreviewImage"]];
}

-(void)setText:(NSString*)n
{
    if (![n isEqualToString:text]) {
        text = [n copy];
        [self updateTextLabel];
    }
}

-(void)setNumberItems:(int)n
{
    if (!(n == numberItems)) {
        numberItems = n;
        [self updateTextLabel];
    }
}

-(void)setDescription:(NSString*)n
{
    if (![n isEqualToString:description]) {
        description = [n copy];
        self.descriptionLabel.text = description;
    }
}

-(void)updateTextLabel
{
    self.textLabel.text = text;
}

-(void)setTextPic:(UIImage*)n
{
    textPic = n;
    [self.textPicImage setImage:textPic];
    [self setNeedsLayout];
}

-(void)setPlaylist:(GDataEntryYouTubePlaylistLink*)playlist
{
    self.playlist = playlist;

    self.text = [[self.playlist title] stringValue];
    self.description = [[self.playlist summary] stringValue];

    [[APPPlaylistImageOfPlaylist instanceWithQueue:[APPGlobals getGlobalForKey:@"queue2"]] process:[NSDictionary dictionaryWithObjectsAndKeys:self.playlist, @"playlist", nil] onCompletion:^(int state, id data, NSError *error) {
        switch (state)
        {
            case tLoaded:
            {
                if (data && !error) {
                    UIImage *image = (UIImage*)data;
                    if (image)
                        self.textPic = image;
                } else {
                    NSLog(@"APPPlaylistImageOfPlaylist: error");
                }
                break;
            }
            default:
            {
                NSLog(@"APPPlaylistImageOfPlaylist: default");
                break;
            }
        }
    }];
}

@end
