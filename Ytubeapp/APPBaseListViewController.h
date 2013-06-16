//
//  APPBaseListViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPProtocols.h"
#import "PervasiveViewController.h"
#import "ViewHelpers.h"
#import "GDataYouTube.h"
#import "APPTableCell.h"
#import "UITableViewHeaderFormView.h"

@interface APPBaseListViewController : PervasiveViewController <Base>
@property (strong, nonatomic) UIImage *topbarImage;
@property (strong, nonatomic) NSString *topbarTitle;
@end