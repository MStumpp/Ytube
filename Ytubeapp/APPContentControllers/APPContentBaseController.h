//
//  APPContentBaseController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPProtocols.h"
#import "GDataYouTube.h"
#import "APPTableView.h"
#import "APPTableCell.h"
#import "UITableViewHeaderFormView.h"
#import "APPQueryHelper.h"
#import "APPGlobals.h"
#import "APPUserManager.h"
#import "FSMUIViewController.h"

#define tUserSignInState @"userSignInState"
#define tUserSignOutState @"userSignOutState"
#define tActiveState @"activeState"
#define tPassiveState @"passiveState"

@interface APPContentBaseController : FSMUIViewController <APPSliderViewControllerDelegate>
+(id)getInstance:(NSString*)identifier withData:(id)data;
+(void)clearInstances;
-(id)initWithData:(id)data;
@property UIImage *topbarImage;
@property NSString *topbarTitle;
@property DataCache *dataCache;
-(void)pushViewController:(UIViewController*)controller;
-(void)popViewController;
-(void)showSignAlert;
-(void)userSignedIn:(NSNotification*)notification;
-(void)userSignedOut:(NSNotification*)notification;
@property bool downAtTopOnly;
@property int downAtTopDistance;
@end