//
//  APPTextCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPTextCell.h"
#import <QuartzCore/QuartzCore.h>

@interface APPTextCell ()
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIImageView *textPicImage;
@end

@implementation APPTextCell

@synthesize text;
@synthesize description;
@synthesize textPic;
@synthesize numberItems;

@synthesize textLabel;
@synthesize descriptionLabel;
@synthesize textPicImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        [self allowToOpen:NO];
        [self setTextPic:[[Helpers classInstance] noPreviewImage]];
    }
    return self;
}

- (void)initUI
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self allowToOpen:NO];
    [self setTextPic:[[Helpers classInstance] noPreviewImage]];
}

- (void)setText:(NSString *)n {
    if (![n isEqualToString:text]) {
        text = [n copy];
        [self updateTextLabel];
    }
}

- (void)setNumberItems:(int)n {
    if (!(n == numberItems)) {
        numberItems = n;
        [self updateTextLabel];
    }
}

- (void)setDescription:(NSString *)n {
    if (![n isEqualToString:description]) {
        description = [n copy];
        descriptionLabel.text = description;
    }
}

- (void)updateTextLabel
{
    textLabel.text = text;
}

- (void)setTextPic:(UIImage *)n {
    textPic = n;
    [textPicImage setImage:textPic];
    [self setNeedsLayout];
}

@end

