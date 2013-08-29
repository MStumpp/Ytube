//
//  UITableViewHeaderFormView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 15.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewHeaderFormViewDelegate;

@interface UITableViewHeaderFormView : UIView
- (id)initWithRootView:(UIView *)rootView headerView:(UIView*)headerView delegate:(id<UITableViewHeaderFormViewDelegate>)delegate;
- (void)showOnCompletion:(void (^)(BOOL isShown))callback animated:(BOOL)animated;
- (void)hideOnCompletion:(void (^)(BOOL isHidden))callback animated:(BOOL)animated;
- (BOOL)isHeaderShown;
- (BOOL)isHeaderHidden;
- (void)setHeaderView:(UIView*)headerView;
- (UIView*)rootView;
- (UIView*)headerView;
@end

@protocol UITableViewHeaderFormViewDelegate <NSObject>

@optional

- (BOOL)tableViewHeaderFormViewShouldShow:(UITableViewHeaderFormView *)view;

- (void)tableViewHeaderFormViewWillShow:(UITableViewHeaderFormView *)view;

- (void)tableViewHeaderFormViewDidShow:(UITableViewHeaderFormView *)view;

- (BOOL)tableViewHeaderFormViewShouldHide:(UITableViewHeaderFormView *)view;

- (void)tableViewHeaderFormViewWillHide:(UITableViewHeaderFormView *)view;

- (void)tableViewHeaderFormViewDidHide:(UITableViewHeaderFormView *)view;

@end
