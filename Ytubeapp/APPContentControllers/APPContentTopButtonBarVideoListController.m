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
    [self toState:[self keyToString:[NSNumber numberWithInt:[sender tag]]]];
}

// "APPTableViewDelegate" Protocol

-(void)beforeShowModeChange
{
    if ([self.tableView showMode] && [self.buttons objectForKey:[self.tableView showMode]])
        [[self.buttons objectForKey:[self.tableView showMode]] setSelected:NO];
}

-(void)afterShowModeChange
{
    if ([self.tableView showMode] && [self.buttons objectForKey:[self.tableView showMode]])
        [[self.buttons objectForKey:[self.tableView showMode]] setSelected:YES];
}

@end