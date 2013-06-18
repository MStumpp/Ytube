//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "APPContentBaseController.h"

@interface APPContentListController : APPContentBaseController <APPTableViewDelegate>
@property (nonatomic, strong) APPTableView *tableView;
@end