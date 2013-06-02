//
//  APPVideoCell.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPTableCell.h"

@interface APPVideoCell : APPTableCell

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

- (void)setHD:(BOOL)n;

@end
