//
//  APPCommentsDetailViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 24.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "GData.h"
#import "APPContentManager.h"
#import "GDataEntryYouTubeComment.h"

#define tAdd 01

@interface APPCommentsDetailViewController : UIViewController

@property (nonatomic, strong) GDataEntryYouTubeComment *comment;
@property (nonatomic, strong) APPContentManager *contentManager;

@property (nonatomic, retain) UIImageView *profilePicImage;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *timeagoLabel;
@property (nonatomic, retain) UITextView *commentLabel;

@end
