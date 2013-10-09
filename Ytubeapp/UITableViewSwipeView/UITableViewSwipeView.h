//
//  UITableViewSwipeView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UITableViewSwipeViewDelegate;

@interface UITableViewSwipeView : NSObject

- (id)initWithTableView:(UITableView *)tableView delegate:(id<UITableViewSwipeViewDelegate>)delegate;

@end

@protocol UITableViewSwipeViewDelegate <NSObject>

@optional

- (BOOL)tableViewSwipeViewCanSwipeLeft:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewSwipeViewDidSwipeLeft:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)tableViewSwipeViewCanSwipeRight:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewSwipeViewDidSwipeRight:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath;

@end