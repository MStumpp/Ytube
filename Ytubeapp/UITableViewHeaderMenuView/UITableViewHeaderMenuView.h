//
//  UITableViewHeaderMenuView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewHeaderMenuViewDelegate;

@interface UITableViewHeaderMenuView : UIView

- (id)initWithTableView:(UITableView *)tableView view:(UIView*)view delegate:(id<UITableViewHeaderMenuViewDelegate>)delegate;
- (void)down:(void (^)(BOOL isDown))callback;
- (void)up:(void (^)(BOOL isUp))callback;
- (void)downAtTopOnly:(BOOL)val;
- (BOOL)isDown;

@end

@protocol UITableViewHeaderMenuViewDelegate <NSObject>

@optional

- (BOOL)tableViewHeaderMenuViewCanShow:(UITableViewHeaderMenuView *)view;

- (void)tableViewHeaderMenuViewWillShow:(UITableViewHeaderMenuView *)view;

- (void)tableViewHeaderMenuViewDidShow:(UITableViewHeaderMenuView *)view;

- (BOOL)tableViewHeaderMenuViewCanHide:(UITableViewHeaderMenuView *)view;

- (void)tableViewHeaderMenuViewWillHide:(UITableViewHeaderMenuView *)view;

- (void)tableViewHeaderMenuViewDidHide:(UITableViewHeaderMenuView *)view;

@end