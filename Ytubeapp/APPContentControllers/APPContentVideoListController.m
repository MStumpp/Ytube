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

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"APPContentVideoListController");
//        [[self configureDefaultState] onViewState:tDidLoadViewState do:^{
//            NSLog(@"APPContentVideoListController: onViewState:tDidLoadViewState");
//            // reloads table view content
//            //[self.tableView clearViewAndReloadAll];
//            //[self.tableView toDefaultShowMode];
//        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView clearViewAndReloadAll];
    [self.tableView toDefaultShowMode];
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(int)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    NSLog(@"cellForRowAtIndexPath");
    APPVideoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
    if (cell == nil)
        cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];

    [cell setVideo:(GDataEntryYouTubeVideo*)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]]];
    return cell;
}

-(void)tableView:(UITableView*)tableView forMode:(int)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    NSLog(@"didSelectRowAtIndexPath");
    if (self.isDefaultMode)
        return;

    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo*)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];

    if (self.afterSelect) {
        [self.navigationController popViewControllerAnimated:YES];
        self.afterSelect(video);
    } else {
        [self.navigationController pushViewController:[[APPContentVideoDetailViewController alloc] initWithVideo:video] animated:YES];
    }
}

@end