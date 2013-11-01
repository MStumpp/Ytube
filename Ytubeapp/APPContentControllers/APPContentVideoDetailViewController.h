//
//  APPContentVideoDetailViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 20.10.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//


#import "APPContentBaseController.h"

@interface APPContentVideoDetailViewController : APPContentBaseController <VideoDependenceDelegate, APPTableViewDelegate, UITableViewHeaderFormViewDelegate, UITableViewMaskViewDelegate, UIWebViewDelegate>
@property int heightVideoView;
@end
