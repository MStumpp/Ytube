//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPContentListController.h"

@interface APPContentTopToggleBarVideoListController : APPContentListController
@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView1;
@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView2;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, retain) NSIndexPath *tmpEditingCell;
@end