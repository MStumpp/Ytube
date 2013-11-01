//
//  APPTableCell.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "APPProtocols.h"
#import "APPTableView.h"

@class APPTableView;

@interface APPTableCell : UITableViewCell
@property UIView *tableCellMain;
@property UIImageView *tableCellSubMenu;
@property APPTableView *__tableView;
@property NSIndexPath *indexPath;
-(void)openOnCompletion:(void (^)(BOOL isOpened))callback animated:(BOOL)animated;
-(void)closeOnCompletion:(void (^)(BOOL isClosed))callback animated:(BOOL)animated;
-(void)cellDidOpen;
-(void)cellDidClose;
-(BOOL)isOpened;
-(BOOL)isClosed;
-(void)allowToOpen:(BOOL)value;
-(void)mask:(BOOL)value;
@end