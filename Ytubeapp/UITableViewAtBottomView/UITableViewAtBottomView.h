//
//  UITableViewAtBottomView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITableViewAtBottomViewDelegate;

@interface UITableViewAtBottomView : NSObject
- (id)initWithTableView:(UITableView *)tableView delegate:(id<UITableViewAtBottomViewDelegate>)delegate;
@end

@protocol UITableViewAtBottomViewDelegate <NSObject>
@optional
- (BOOL)tableViewCanBottom:(UITableView *)view;
- (void)tableViewDidBottom:(UITableView *)view;
@end