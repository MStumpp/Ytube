//
// Created by Matthias Stumpp on 17.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentVideoListController.h"
#import "APPContentVideoDetailViewController.h"
#import "APPVideoCell.h"

@implementation APPContentVideoListController

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    APPVideoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
    if (cell == nil)
        cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];

    [cell setVideo:(GDataEntryYouTubeVideo*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]]];
    return cell;
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if ([self inState:tPassiveState]) return;

    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    APPContentVideoDetailViewController *videoController = [[APPContentVideoDetailViewController alloc] initWithVideo:video];
    [self pushViewController:videoController];
}

@end