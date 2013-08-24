//
//  APPContentBaseController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPProtocols.h"
#import "ViewHelpers.h"
#import "GDataYouTube.h"
#import "APPTableCell.h"
#import "UITableViewHeaderFormView.h"
#import "APPQueryHelper.h"
#import "APPGlobals.h"
#import "APPUserManager.h"
#import "StatefulUIViewController.h"

@interface APPContentBaseController : StatefulUIViewController
@property UIImage *topbarImage;
@property NSString *topbarTitle;
@property BOOL isDefaultMode;
-(void)didShow:(void (^)(void))callback;
-(void)willHide:(void (^)(void))callback;
-(void)processEvent:(NSNotification*)notification;
-(void)resetController;
-(void)clearContent;
-(void)loadContent;
@end