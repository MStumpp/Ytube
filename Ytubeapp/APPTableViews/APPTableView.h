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
@property NSIndexPath *openCell;
-(BOOL)addShowMode:(NSString*)mode;
-(BOOL)addDefaultShowMode:(NSString*)mode;
-(void)toShowMode:(NSString*)mode;
-(void)toShowModeForce:(NSString*)mode;
-(void)toDefaultShowMode;
-(void)toDefaultShowModeForce;
-(void)clearView;
-(void)clearViewAndReload;
-(void)dataReloadedFinished:(NSString*)mode;
-(void)dataReloadedError:(NSString*)mode;
-(void)loadedMoreFinished:(NSString*)mode;
-(void)loadedMoreError:(NSString*)mode;
-(void)openCell:(NSIndexPath*)indexPath onCompletion:(void (^)(BOOL isOpen))callback;
-(void)closeCell:(NSIndexPath*)indexPath onCompletion:(void (^)(BOOL isClose))callback;
@end

@protocol APPTableViewDelegate
@required
-(CGFloat)tableView:(UITableView*)tableView forMode:(NSString*)mode heightForRowAtIndexPath:(NSIndexPath*)indexPath;
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
-(void)pushViewController:(UIViewController*)controller;
@end