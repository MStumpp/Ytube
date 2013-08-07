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
#import "QueryTicket.h"
#import "APPQueryHelper.h"
#import "APPGlobals.h"
#import "APPUserManager.h"

@interface APPContentBaseController : UIViewController<State>
@property (strong, nonatomic) UIImage *topbarImage;
@property (strong, nonatomic) NSString *topbarTitle;
@property BOOL isDefaultMode;
-(void)didShow:(void (^)(void))callback;
-(void)willHide:(void (^)(void))callback;
-(void)processEvent:(NSNotification*)notification;
@end