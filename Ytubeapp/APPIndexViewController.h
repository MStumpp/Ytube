//
//  APPIndexViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "APPContentManager.h"
#import "PervasiveViewController.h"

@interface APPIndexViewController : PervasiveViewController <UINavigationControllerDelegate>

-(void)setToolbarBackgroundImage:(UIImage*)image;
-(void)setToolbarTitle:(NSString*)title;

-(void)signOutOnCompletion:(void (^)(BOOL isSignedOut))callback;

-(void)unselectButtons;

@end