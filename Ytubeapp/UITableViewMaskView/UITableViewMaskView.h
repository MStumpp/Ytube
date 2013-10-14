//
//  UITableViewMaskView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 17.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewMaskViewDelegate;

@interface UITableViewMaskView : NSObject
- (id)initWithRootView:(UIView *)rootView customMaskView:(UIView*)customMaskView delegate:(id<UITableViewMaskViewDelegate>)delegate;
- (void)maskOnCompletion:(void (^)(BOOL isMasked))callback;
- (void)unmaskOnCompletion:(void (^)(BOOL isUnmasked))callback;
- (BOOL)isMasked;
- (BOOL)isUnmasked;
-(void)setAlphaValue:(float)n;
-(void)showSpinner:(BOOL)n;
@end

@protocol UITableViewMaskViewDelegate <NSObject>
@optional
- (BOOL)tableViewMaskViewCanMask:(UITableViewMaskView *)view;
- (void)tableViewMaskViewWillMask:(UITableViewMaskView *)view;
- (void)tableViewMaskViewDidMask:(UITableViewMaskView *)view;
- (BOOL)tableViewMaskViewCanUnmask:(UITableViewMaskView *)view;
- (void)tableViewMaskViewWillUnmask:(UITableViewMaskView *)view;
- (void)tableViewMaskViewDidUnmask:(UITableViewMaskView *)view;
@end