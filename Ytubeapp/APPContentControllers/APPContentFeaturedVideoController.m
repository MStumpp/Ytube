//
// Created by Matthias Stumpp on 17.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentFeaturedVideoController.h"

@implementation APPContentFeaturedVideoController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_featured"];
    }
    return self;
}

-(QueryTicket*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    return [APPQueryHelper featuredVideosOnShowMode:mode withPrio:prio delegate:tableView];
}

-(QueryTicket*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)prio
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:prio delegate:tableView];
}

@end