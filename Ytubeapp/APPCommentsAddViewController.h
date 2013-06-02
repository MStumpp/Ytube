//
//  APPCommentsAddViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 25.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPBaseListViewController.h"
#import "GDataEntryYouTubeVideo.h"

@interface APPCommentsAddViewController : APPBaseListViewController

@property (nonatomic, retain) GDataEntryYouTubeVideo *video;
@property (nonatomic, retain) APPContentManager *contentManager;

@property (nonatomic, retain) UIImageView *profilePicImage;
@property (nonatomic, retain) UILabel *nameLabel;

@end
