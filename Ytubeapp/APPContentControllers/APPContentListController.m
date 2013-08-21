//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentListController.h"

@implementation APPContentListController

-(void)loadView
{
    [super loadView];
    self.tableView = [[APPTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height-44.0) style:UITableViewStylePlain];
    self.tableView._del = self;
}

-(NSIndexPath*)tableView:(UITableView*)tableView forMode:(int)mode willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.isDefaultMode)
        return nil;

    return indexPath;
}

-(BOOL)tableViewCanBottom:(UITableView*)view
{
    if (self.isDefaultMode)
        return FALSE;

    return TRUE;
}

-(BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView*)view
{
    if (self.isDefaultMode)
        return FALSE;

    return TRUE;
}

-(void)beforeShowModeChange
{
    return;
}

-(void)afterShowModeChange
{
    return;
}

-(void)clearContent
{
    [self.tableView clearView];
}

@end