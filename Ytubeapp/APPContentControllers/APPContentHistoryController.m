//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentHistoryController.h"

@implementation APPContentHistoryController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_history"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventVideoWatched object:nil];

        [[self configureDefaultState] onViewState:tDidLoadViewState do:^{
            // reloads table view content
            [self.tableView clearViewAndReloadAll];
            [self.tableView toDefaultShowMode];
        }];
        [self toDefaultStateForce];
    }
    return self;
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper historyVideosOnShowMode:mode withPrio:p delegate:tableView];
}

-(Query*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)p
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:p delegate:tableView];
}

-(void)processEvent:(NSNotification*)notification
{
    if (![(NSDictionary*)[notification object] objectForKey:@"error"])
        [self.tableView clearViewAndReloadAll];
}

@end