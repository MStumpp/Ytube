//
//  TVNavigationController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 04.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVNavigationController : UINavigationController <UINavigationControllerDelegate> {
    UIViewController *fakeRootViewController;
}

@property(nonatomic, retain) UIViewController *fakeRootViewController;
@property(nonatomic, retain) id<UINavigationControllerDelegate> _delegate_;

-(void)setRootViewController:(UIViewController *)rootViewController;
-(void)pushViewController:(UIViewController *)viewController onCompletion:(void (^)(BOOL pushed))callback context:(id)context animated:(BOOL)animated;
-(void)popViewControllerOnCompletion:(void (^)(BOOL popped))callback context:(id)context animated:(BOOL)animated;

@end

@protocol TVNavigationControllerDelegate
@optional
-(void)willBePushed:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context;
-(void)willBePopped:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context;
-(void)didFullScreenAfterPush:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context;
-(void)didFullScreenAfterPop:(void (^)(void))callback controller:(UIViewController*)controller context:(id)context;
@end