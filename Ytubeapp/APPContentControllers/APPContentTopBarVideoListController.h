//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPContentVideoListController.h"
#import "UITableViewHeaderFormView.h"

static bool downAtTopOnly = TRUE;
static int downAtTopDistance = 40;

@interface APPContentTopBarVideoListController : APPContentVideoListController <UITableViewHeaderFormViewDelegate>
@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView;
@end