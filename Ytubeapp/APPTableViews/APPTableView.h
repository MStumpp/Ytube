//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPTableCell.h"
#import "Query.h"

@protocol APPTableViewDelegate;

@class APPTableCell;

@interface APPTableView : UITableView <UITableViewDataSource, UITableViewDelegate, UITableViewAtBottomViewDelegate, SSPullToRefreshViewDelegate, UITableViewSwipeViewDelegate, UITableViewMaskViewDelegate>
@property id<APPTableViewDelegate> _del;
@property NSString *showMode;
-(BOOL)addShowMode:(NSString*)mode;
-(BOOL)addDefaultShowMode:(NSString*)mode;
-(void)toShowMode:(NSString*)mode;
-(void)toDefaultShowMode;
-(void)clearView;
-(void)clearViewAndReloadAll;
-(void)dataReloadedFinished:(NSString*)mode;
-(void)dataReloadedError:(NSString*)mode;
-(void)loadedMoreFinished:(NSString*)mode;
-(void)loadedMoreError:(NSString*)mode;
@end

@protocol APPTableViewDelegate
@required
-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(int)tableView:(UITableView*)tableView forMode:(NSString*)mode numberOfRowsInSection:(NSInteger)section;
-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(NSString*)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)tableView:(UITableView*)tableView canOpenCellforMode:(NSString*)mode forRowAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)hasData:(NSString*)mode;
-(void)reloadData:(NSString*)mode;
-(void)loadMoreData:(NSString*)mode;
-(void)clearData:(NSString*)mode;
-(BOOL)tableViewCanBottom:(UITableView*)view;
-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view;
-(void)beforeShowModeChange;
-(void)afterShowModeChange;
@optional
-(void)pushViewController:(UIViewController*)controller;
@end