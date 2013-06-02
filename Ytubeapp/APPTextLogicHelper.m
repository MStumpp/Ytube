//
//  APPTextLogicHelper.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 17.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPTextLogicHelper.h"

@implementation APPTextLogicHelper

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath delegate:(id<Base, HasTableView>)delegate
{
    APPTextCell *cell = [delegate.tableView dequeueReusableCellWithIdentifier:@"APPTextCell"];
    if (cell == nil) {
        cell = [[APPTextCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPTextCell"];
    }
    
    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink *) [[delegate currentCustomFeed] objectAtIndex:[indexPath row]];
    
    cell.text = [[playlist title] stringValue];
    cell.description = [[playlist summary] stringValue];
    
    [delegate.contentManager imageForPlaylist:playlist callback:^(UIImage *image) {
        if (image)
            cell.textPic = image;
    }];
    
    return cell;
}

+ (void)deletePlaylist:(GDataEntryYouTubePlaylistLink*)playlist delegate:(id<Base, HasTableView, State>)delegate
{
    [delegate.contentManager deletePlaylist:playlist callback:^(BOOL deleted, NSError *error) {
        if (deleted && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deletedPlaylist" object:playlist];

        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to delete your playlist. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

@end
