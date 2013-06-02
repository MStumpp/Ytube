//
//  APPVideoListViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPVideoListViewController.h"
#import "APPVideoCell.h"
#import "APPVideoDetailViewController.h"
#import "APPCommentsListViewController.h"
#import "APPPlaylistsViewController.h"

@implementation APPVideoListViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    APPVideoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
    if (cell == nil) {
        cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];
    }
    
    cell.touchButtonDelegate = self;
    cell.touchButtonIndexPath = indexPath;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
    
    [self.contentManager isVideoFavorite:video callback:^(GDataEntryYouTubeFavorite *fav, NSError *error) {
        if (fav) {
            [cell.favoritesButton setSelected:YES];
        } else {
            [cell.favoritesButton setSelected:NO];
        }
    }];
    
    [self.contentManager isVideoWatchLater:video callback:^(GDataEntryYouTubeVideo *video, NSError *error) {
        if (video) {
            [cell.watchLaterButton setSelected:YES];
        } else {
            [cell.watchLaterButton setSelected:NO];
        }
    }];

    cell.title = [[video title] stringValue];
    cell.subtitle = [[video title] stringValue];
    
    cell.numberlikes = [[[video rating] numberOfLikes] intValue];
    cell.numberdislikes = [[[video rating] numberOfLikes] intValue];
    cell.views = [[[video statistics] viewCount] intValue];
    
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    cell.durationinseconds = [[mediaGroup duration] intValue];
    
    [self.contentManager imageForVideo:video callback:^(UIImage *image) {
        if (image) {
            cell.thumbnail = image;
            [cell setNeedsLayout];
        }
    }];
    
    return cell;
}

- (void)tableViewCellButtonTouched:(APPTableCell *)cell button:(UIButton *)button indexPath:(NSIndexPath *)indexPath
{    
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];

    switch (button.tag)
    {
        case tAddToPlaylist:
            
            APPPlaylistsViewController *playlistController = [[APPPlaylistsViewController alloc] init];
            playlistController.callback = ^(GDataEntryYouTubePlaylistLink *playlist) {
                [self.navigationController popViewControllerAnimated:YES];
                [self.contentManager addVideoToPlaylist:video playlist:playlist callback:^(GDataEntryYouTubePlaylist *playlist, NSError *error) {
                    if (playlist && !error) {
                        [[[UIAlertView alloc] initWithTitle:@"Video Added"
                                                    message:[NSString stringWithFormat:@"Video added to playlist: %@", [[playlist title] stringValue]]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                    } else
                        [[[UIAlertView alloc] initWithTitle:@"Video Not Added"
                                                    message:[NSString stringWithFormat:@"Something went wrong. Video not added to playlist: %@", [[playlist title] stringValue]]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                }];
            };
            [self.navigationController pushViewController:playlistController animated:YES];
            break;
            
        case tWatchLater:
    
            if ([button isSelected]) {
                [button setSelected:FALSE];
                [self.contentManager removeVideoFromWatchLater:video callback:^(BOOL removed, NSError *error){
                    if (error || !removed)
                        [button setSelected:TRUE];
                }];
                
            } else {
                [button setSelected:TRUE];
                [self.contentManager addVideoToWatchLater:video callback:^(GDataEntryYouTubePlaylist *tmp_video, NSError *error) {
                    if (error || !tmp_video)
                        [button setSelected:FALSE];
                }];
            }
            break;

        case tFavorites:
                    
            if ([button isSelected]) {
                [button setSelected:FALSE];
                [self.contentManager removeVideoFromFavorites:video callback:^(BOOL removed, NSError *error) {
                    if (error || !removed)
                        [button setSelected:TRUE];
                }];
                
            } else {
                [button setSelected:TRUE];
                [self.contentManager addVideoToFavorites:video callback:^(GDataEntryYouTubeFavorite *tmp_video, NSError *error) {
                    if (error || !tmp_video)
                        [button setSelected:FALSE];
                }];
            }
            break;
            
        case tComments:
        
            [self.navigationController pushViewController:[[APPCommentsListViewController alloc] initWithVideo:video] animated:YES];
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTableCell *selectedCell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (![selectedCell isOpen]) {
        APPVideoDetailViewController *detailController = [[APPVideoDetailViewController alloc] init];
        detailController.video = [[self currentCustomFeed] objectAtIndex:[indexPath row]];
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

@end
