//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPContentListController.h"

@interface APPContentTopToggleBarListController : APPContentListController <UITableViewHeaderFormViewDelegate>
@property UITableViewHeaderFormView *tableViewHeaderFormView1;
@property UITableViewHeaderFormView *tableViewHeaderFormView2;
@property UIButton *backButton;
@property UIButton *editButton;
@property NSIndexPath *tmpEditingCell;
@end