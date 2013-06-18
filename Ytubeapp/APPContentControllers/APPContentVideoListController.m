//
// Created by Matthias Stumpp on 17.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentVideoListController.h"
#import "APPVideoDetailViewController.h"
#import "APPVideoCell.h"

@implementation APPContentVideoListController

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPVideoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
    if (cell == nil) {
        cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];
    }
    [cell setVideo:(GDataEntryYouTubeVideo *)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectEntry:(GDataEntryBase*)entry
{
    if (!self.isDefaultMode) {
        APPVideoDetailViewController *videoDetailController = [[APPVideoDetailViewController alloc] initWithVideo:entry];
        [self.navigationController pushViewController:videoDetailController animated:YES];
    }
}

@end