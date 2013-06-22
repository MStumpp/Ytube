//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPContentVideoListController.h"

@interface APPContentTopBarVideoListController : APPContentVideoListController <UITableViewHeaderFormViewDelegate>
@property BOOL downAtTopOnly;
@property int downAtTopDistance;
@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView;
@end