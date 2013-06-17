//
//  APPSingleTableCustomBarVideoListViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 10.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableCustomBarVideoListViewController.h"
#import "APPVideoLogicHelper.h"

@implementation APPSingleTableCustomBarVideoListViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [APPVideoLogicHelper tableView:tableView cellForRowAtIndexPath:indexPath delegate:self];
}

- (void)tableViewCellButtonTouched:(APPTableCell *)cell button:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
    [APPVideoLogicHelper videoAction:video button:button delegate:self];
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [APPVideoLogicHelper tableView:tableView willSelectRowAtIndexPath:indexPath delegate:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [APPVideoLogicHelper tableView:tableView didSelectRowAtIndexPath:indexPath delegate:self];
}

@end
