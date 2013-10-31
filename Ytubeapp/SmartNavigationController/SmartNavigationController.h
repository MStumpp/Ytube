//
//  SmartNavigationController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 04.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartNavigationController : UINavigationController
-(void)setRootViewController:(UIViewController*)rootViewController;
@end

@protocol SmartNavigationControllerDelegate
@optional
// push operation
// called on the controller the other controller is pushed on top, called before the actual push
// controller = the controller that's pushed on top
-(void)navigationController:(UINavigationController*)navController willBePushed:(UIViewController*)controller context:(id)context onCompletion:(void (^)(void))callback;

// pop operation
// called on the controller that will be popped, called before the actual pop
// controller = the controller that's on top after the pop
-(void)navigationController:(UINavigationController*)navController willBePopped:(UIViewController*)controller context:(id)context onCompletion:(void (^)(void))callback;

// called on the controller that's visible after the push, called after the actual push operation
// controller = the controller that was previously on top
-(void)navigationController:(UINavigationController*)navController didPush:(UIViewController*)controller context:(id)context onCompletion:(void (^)(void))callback;

// called on the controller that's visible after the pop, called after the actual pop operation
// controller = the controller(s) that was(were) previously on above
-(void)navigationController:(UINavigationController*)navController didPop:(UIViewController*)controller context:(id)context onCompletion:(void (^)(void))callback;

@end