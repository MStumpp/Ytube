//
//  APPSingleTableCustomBarView.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableCustomBarView.h"

@implementation APPSingleTableCustomBarView

+(UIView*)loadWithView:(UIView*)view delegate:(id<APPSingleTableCustomBarViewDelegate>)delegate;
{
    UITableView *tableView = (UITableView*) [APPSingleTableView loadWithView:view delegate:delegate];
    
    delegate.tableViewHeaderFormView = [[UITableViewHeaderFormView alloc] initWithRootView:tableView headerView:nil delegate:delegate];
    
    return tableView;
}

@end
