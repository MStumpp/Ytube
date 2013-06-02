//
//  APPChannelsViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPChannelsViewController.h"

@interface APPChannelsViewController ()

@end

@implementation APPChannelsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_channels"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self load];
}

- (void)load
{
    [self.contentManager channelsDelegate:self didFinishSelector:@selector(request:finishedWithFeed:error:)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPTextCell"];
    if (cell == nil) {
        cell = [[APPTextCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPTextCell"];
    }
    
    return cell;
}

@end
