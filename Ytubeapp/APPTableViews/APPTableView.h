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

@protocol APPTableViewDelegate;
@protocol APPTableViewProcessResponse;

@class QueryTicket;

@class APPTableCell;

@interface APPTableView : UITableView <UITableViewDataSource, UITableViewDelegate, SSPullToRefreshViewDelegate, UITableViewSwipeViewDelegate, UITableViewAtBottomViewDelegate, UITableViewMaskViewDelegate, APPTableViewProcessResponse>
@property id<APPTableViewDelegate> _delegate;
-(void)toShowMode:(int)mode;
-(void)addShowMode:(int)mode;
-(int)showMode;
-(NSMutableArray*)currentCustomFeed;
-(NSMutableArray*)currentCustomFeedForShowMode:(int)mode;
-(void)reloadShowMode;
@end

@protocol APPTableViewProcessResponse
@required
-(void)reloadDataResponse:(NSDictionary*)args;
-(void)loadMoreDataResponse:(NSDictionary*)args;
@end

@protocol APPTableViewDelegate
@required
-(APPTableCell*)tableView:(UITableView*)tableView forMode:(int)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView*)tableView forMode:(int)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView*)tableView forMode:(int)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
-(QueryTicket*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio;
-(QueryTicket*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)prio;
@optional
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)tableViewCanBottom:(UITableView*)view;
-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view;
-(void)beforeShowModeChange;
-(void)afterShowModeChange;
-(void)pushViewController:(UIViewController*)controller;
@end