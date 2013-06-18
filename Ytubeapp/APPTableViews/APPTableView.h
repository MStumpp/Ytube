//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPTableCell.h"

@protocol APPTableViewDelegate;
@class QueryTicket;

@interface APPTableView : UITableView <UITableViewDataSource, UITableViewDelegate, TouchButtonTableViewCellDelegate, SSPullToRefreshViewDelegate, UITableViewSwipeViewDelegate, UITableViewAtBottomViewDelegate, UITableViewMaskViewDelegate>
@property id<APPTableViewDelegate> _delegate;
-(void)toShowMode:(int)mode;
-(void)addShowMode:(int)mode;
-(int)showMode;
-(NSMutableArray*)currentCustomFeed;
@end

@protocol APPTableViewDelegate
@required
-(APPTableCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle didSelectEntry:(GDataEntryBase*)entry;
-(void)tableView:(UITableView*)tableView didSelectEntry:(GDataEntryBase*)entry;
-(BOOL)tableViewCanBottom:(UITableView*)view;
-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view;
-(QueryTicket*)reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio
-(QueryTicket*)loadMoreDataConcreteForShowMode:(int)mode withPrio:(int)prio
@optional
-(void)beforeShowModeChange;
-(void)afterShowModeChange;
@end