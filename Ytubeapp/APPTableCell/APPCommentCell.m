//
//  APPCommentCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPCommentCell.h"
#import "NSDate+TimeAgo.h"
#import "APPGlobals.h"
#import "APPVideoImageOfComment.h"

@interface APPCommentCell()
@property (nonatomic) GDataEntryYouTubeComment *comment;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *commentText;
@property (nonatomic) UIImage *profilePic;
@property (nonatomic) NSDate *date;
@property (nonatomic) BOOL open;
@property BOOL showFullComment;
@property UILabel *nameLabel;
@property UILabel *commentLabel;
@property UILabel *timeagoLabel;
@property UIImageView *profilePicImage;
@end

@implementation APPCommentCell
@synthesize comment;
@synthesize name;
@synthesize commentText;
@synthesize profilePic;
@synthesize date;
@synthesize open;

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
    self.commentLabel.numberOfLines = 4;

    [self.commentLabel setBackgroundColor:[UIColor clearColor]];
    [self.tableCellMain addSubview:self.commentLabel];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.open = NO;
    [self setProfilePic:[[APPGlobals classInstance] getGlobalForKey:@"silhouetteImage"]];
}

-(void)setName:(NSString*)n
{
    if (![n isEqualToString:name]) {
        name = [n copy];
        self.nameLabel.text = name;
    }
}

-(void)setCommentText:(NSString*)n
{
    if (![n isEqualToString:commentText]) {
        commentText = [n copy];
        self.commentLabel.text = commentText;
    }
}

-(void)setDate:(NSDate*)n
{
    if (!(n == date)) {
        date = n;
        self.timeagoLabel.text = [date timeAgo];
    }
}

-(void)setProfilePic:(UIImage*)n
{
    profilePic = n;
    [self.profilePicImage setImage:profilePic];
}

-(void)setOpen:(BOOL)n
{
    if (!(n == open)) {
        open = n;
        if (open) {
            CGSize s = [commentText sizeWithFont:[UIFont fontWithName: @"Nexa Light" size:12] constrainedToSize:CGSizeMake(215.0, MAXFLOAT)];
            self.commentLabel.frame = CGRectMake(85.0, 30.0, 215.0, s.height);
            self.commentLabel.numberOfLines = (int) s.height / 12.0;
        } else {
            self.commentLabel.frame = CGRectMake(85.0, 30.0, 215.0, 48.0);
            self.commentLabel.numberOfLines = 4;
        }
    }
}

-(NSUInteger)cellHeightFullComment
{
    CGSize s = [commentText sizeWithFont:[UIFont fontWithName: @"Nexa Light" size:12] constrainedToSize:CGSizeMake(215.0, MAXFLOAT) lineBreakMode:self.commentLabel.lineBreakMode];
    NSUInteger cellHeight = s.height + 30.0 + 12.0;
    return cellHeight >= 88.0 ? cellHeight : 88.0;
}

-(void)setComment:(GDataEntryYouTubeComment*)c
{
    comment = c;

    if ([comment authors])
        self.name = [(GDataPerson*)[[comment authors] objectAtIndex:0] name];
    if ([comment content])
        self.commentText = [[comment content] stringValue];
    if ([comment updatedDate])
        self.date = [[comment updatedDate] date];

    [[APPVideoImageOfComment instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
        execute:[NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil]
        context:[NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil]
        onStateChange:^(NSString *state, id data, NSError *error, id context) {
            if ([state isEqual:tFinished]) {
                if (!error) {
                    UIImage *image = (UIImage*)data;
                    if (image)
                        self.profilePic = image;
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                             message:[NSString stringWithFormat:@"Unable to fetch profile picture for user."]
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
                }
            }
    }];
}

@end
