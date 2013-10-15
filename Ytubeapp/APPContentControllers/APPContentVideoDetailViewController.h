//
//  APPContentVideoDetailViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.10.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//


#import "APPContentBaseController.h"

static bool downAtTopOnly = TRUE;
static int downAtTopDistance = 40;
static int heightVideoView = 186.0;

@interface APPContentVideoDetailViewController : APPContentBaseController <VideoDependenceDelegate, APPTableViewDelegate, UITableViewHeaderFormViewDelegate, UITableViewMaskViewDelegate, UIWebViewDelegate>

@end
