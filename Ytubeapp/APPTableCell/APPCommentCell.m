//
//  APPCommentCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+TimeAgo.h"

@interface APPCommentCell ()
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UILabel *timeagoLabel;
@property (strong, nonatomic) UIImageView *profilePicImage;
@end

@implementation APPCommentCell

@synthesize name;
@synthesize comment;
@synthesize date;
@synthesize profilePic;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.showFullComment = FALSE;
        [self allowToOpen:NO];
        [self setProfilePic:[[ViewHelpers classInstance] silhouetteImage]];
    }
    return self;
}

- (void)initUI
{  
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 12.0, 200.0, 12.0)];
    [self.nameLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:10]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.nameLabel];
    
    self.timeagoLabel = [[UILabel alloc] initWithFrame:CGRectMake(235.0, 12.0, 100.0, 12.0)];
    [self.timeagoLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:10]];
    [self.timeagoLabel setTextColor:[UIColor grayColor]];
    [self.timeagoLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.timeagoLabel];
    
    self.profilePicImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 30.0, 48.0, 48.0)];
    [self.tableCellMain addSubview:self.profilePicImage];
    
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 30.0, 215.0, 48.0)];
    [self.commentLabel setFont:[UIFont fontWithName: @"Nexa Light" size:12]];
    [self.commentLabel setTextColor:[UIColor whiteColor]];
    self.commentLabel.adjustsLetterSpacingToFitWidth = NO;
    self.commentLabel.numberOfLines = 4;
    //[self.commentLabel sizeToFit];
    
    /*CGRect myFrame = self.commentLabel.frame;
    if (myFrame.size.height > 4*12.0)
        self.commentLabel.frame = CGRectMake(self.commentLabel.frame.origin.x, self.commentLabel.frame.origin.y, self.commentLabel.frame.size.width, 48.0);*/
    
    [self.commentLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.commentLabel];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.showFullComment = FALSE;
    [self allowToOpen:NO];
    [self setProfilePic:[[ViewHelpers classInstance] silhouetteImage]];
}

/*- (void)layoutSubviews
{
    [super layoutSubviews];
    //CGSize s = [self.comment sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(215.0, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    //self.commentLabel.frame = CGRectMake(85.0, 30.0, s.width, s.height);
}*/

- (void)setName:(NSString *)n {
    if (![n isEqualToString:name]) {
        name = [n copy];
        self.nameLabel.text = name;
    }
}

- (void)setComment:(NSString *)n {
    comment = [n copy];
    self.commentLabel.text = comment;
    if (self.showFullComment) {
        [self.commentLabel setNumberOfLines:0];
        [self.commentLabel sizeToFit];

        /*NSUInteger characterCount = [comment length];
        self.commentLabel.frame = CGRectMake(self.commentLabel.frame.origin.x, self.commentLabel.frame.origin.y, self.commentLabel.frame.size.width, (characterCount / 25) * 12);
        //NSLog(@"height: %d", characterCount / 30);
        self.commentLabel.numberOfLines = characterCount / 25;*/
    }
}

- (void)setDate:(NSDate *)n {
    if (!(n == date)) {
        date = n;
        self.timeagoLabel.text = [date timeAgo];
    }
}

- (void)setProfilePic:(UIImage *)n {
    profilePic = n;
    [self.profilePicImage setImage:profilePic];
}

- (NSUInteger)cellHeightFullComment
{
    //CGSize maximumSize = CGSizeMake(300, 9999);
    /*CGSize dateStringSize = [comment sizeWithFont:[UIFont fontWithName: @"Nexa Light" size:12]
                                   constrainedToSize:maximumSize
                                       lineBreakMode:self.commentLabel.lineBreakMode];*/
    
    NSUInteger cellHeight = ([comment length] / 27.0) * 12.0 + 30.0 + 16.0;
    //NSUInteger cellHeight = dateStringSize.height + 30.0 + 16.0;
    return cellHeight > 88.0 ? cellHeight : 88.0;
}

@end
