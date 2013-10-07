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
@property GDataEntryYouTubePlaylistLink *playlist;
@property NSString *text;
@property NSString *description;
@property UIImage *textPic;
@property int numberItems;
@property UILabel *textLabel;
@property UILabel *descriptionLabel;
@property UIImageView *textPicImage;
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
    [self setTextPic:[[APPGlobals classInstance] getGlobalForKey:@"noPreviewImage"]];
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

    [[APPPlaylistImageOfPlaylist instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
            execute:[NSDictionary dictionaryWithObjectsAndKeys:self.playlist, @"playlist", nil]
            context:NULL
      onStateChange:^(NSString *state, id data, NSError *error, id context) {
          if ([state isEqual:tFinished]) {
              if (!error) {
                  UIImage *image = (UIImage*)data;
                  if (image)
                      self.textPic = image;
              } else {
                  NSLog(@"APPPlaylistImageOfPlaylist: error");
              }
          }
      }];
}

@end

