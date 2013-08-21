//
// Created by Matthias Stumpp on 17.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopButtonBarVideoListController.h"

@implementation APPContentTopButtonBarVideoListController

-(void)subtopbarButtonPress:(UIButton*)sender
{
    NSLog(@"subtopbarButtonPress");
    [self.tableView toShowMode:[sender tag]];
}

// "APPTableView" Protocol

-(void)beforeShowModeChange
{
    NSLog(@"beforeShowModeChange");
    if ([self.tableView showMode] && [self.buttons objectForKey:[NSNumber numberWithInt:[self.tableView showMode]]])
        [[self.buttons objectForKey:[NSNumber numberWithInt:[self.tableView showMode]]] setSelected:NO];
}

-(void)afterShowModeChange
{
    NSLog(@"afterShowModeChange");
    if ([self.tableView showMode] && [self.buttons objectForKey:[NSNumber numberWithInt:[self.tableView showMode]]])
        [[self.buttons objectForKey:[NSNumber numberWithInt:[self.tableView showMode]]] setSelected:YES];
}

@end