//
//  APPAppDelegate.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//


#import <UIKit/UIKit.h>

@class APPIndexViewController;

@interface APPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) APPIndexViewController *viewController;

@end
