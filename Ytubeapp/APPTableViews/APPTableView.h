//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPTableCell.h"

#define tPreload 01
#define tVisibleload 02
#define tMode @"mode"
#define tError @"error"
#define tFeed @"feed"

@protocol APPTableViewProcessResponse;
@protocol APPTableViewDelegate;

@class APPTableCell;
@class QueryTicket;

@interface APPTableView : UITableView <UITableViewDataSource, UITableViewDelegate, UITableViewAtBottomViewDelegate,
        SSPullToRefreshViewDelegate, UITableViewSwipeViewDelegate, UITableViewMaskViewDelegate, APPTableViewProcessResponse>
@property id<APPTableViewDelegate> _delegate;
-(BOOL)addShowMode:(int)mode;
-(void)toShowMode:(int)mode;
-(int)showMode;
-(void)reloadDataAll;
-(NSMutableArray*)currentCustomFeed;
@end

@protocol APPTableViewProcessResponse
@required
-(void)reloadDataResponse:(NSDictionary*)args;
-(void)loadMoreDataResponse:(NSDictionary*)args;
@end

@protocol APPTableViewDelegate
@required
-(APPTableCell*)tableView:(UITableView*)tableView forMode:(int)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(int)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView*)tableView forMode:(int)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView*)tableView forMode:(int)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath*)indexPath;
-(QueryTicket*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio;
-(QueryTicket*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode
        forFeed:(GDataFeedBase*)feed withPrio:(int)prio;
@optional
-(BOOL)tableViewCanBottom:(UITableView*)view;
-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view;
-(void)beforeShowModeChange;
-(void)afterShowModeChange;
-(void)pushViewController:(UIViewController*)controller;
@end