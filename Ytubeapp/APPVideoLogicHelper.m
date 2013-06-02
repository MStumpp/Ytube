//
//  APPVideoLogicHelper.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 16.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPVideoLogicHelper.h"
#import "APPPlaylistsViewController.h"
#import "APPCommentsListViewController.h"
#import "APPVideoDetailViewController.h"
#import "APPVideoCell.h"

@implementation APPVideoLogicHelper

+ (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath delegate:(id<Base, HasTableView>)delegate
{
    APPVideoCell *cell = [delegate.tableView dequeueReusableCellWithIdentifier:@"APPVideoCell"];
    if (cell == nil) {
        cell = [[APPVideoCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPVideoCell"];
        cell.touchButtonDelegate = delegate;
    }
    
    if (delegate.openCell && [delegate.openCell row] == [indexPath row])
        [cell openOnCompletion:NULL animated:NO];
    
    cell.touchButtonIndexPath = indexPath;
    
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *) [[delegate currentCustomFeed] objectAtIndex:[indexPath row]];
    
    [delegate.contentManager isVideoFavorite:video callback:^(GDataEntryYouTubeFavorite *fav, NSError *error) {
        if (fav)
            [cell.favoritesButton setSelected:YES];
    }];
    
    [delegate.contentManager isVideoWatchLater:video callback:^(GDataEntryYouTubeVideo *video, NSError *error) {
        if (video)
            [cell.watchLaterButton setSelected:YES];
    }];
    
    cell.title = [[video title] stringValue];
    cell.subtitle = [[video title] stringValue];
    
    cell.numberlikes = [[[video rating] numberOfLikes] intValue];
    cell.numberdislikes = [[[video rating] numberOfDislikes] intValue];
    cell.views = [[[video statistics] viewCount] intValue];
    
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    cell.durationinseconds = [[mediaGroup duration] intValue];
    
    [delegate.contentManager imageForVideo:video callback:^(UIImage *image) {
        if (image) {
            cell.thumbnail = image;
            [cell setNeedsLayout];
        }
    }];
    
    return cell;
}

+ (void)videoAction:(GDataEntryYouTubeVideo*)video button:(UIButton*)button delegate:(id<Base, HasTableView, VideoDependenceDelegate>)delegate
{    
    switch (button.tag)
    {
        case tAddToPlaylist:
        {
            APPPlaylistsViewController *playlistController = [[APPPlaylistsViewController alloc] init];
            playlistController.callback = ^(GDataEntryYouTubePlaylistLink *playlist) {
                [[delegate getNavigationController] popViewControllerAnimated:YES];
                [delegate.contentManager addVideoToPlaylist:video playlist:playlist callback:^(GDataEntryYouTubePlaylist *playlist, NSError *error) {
                    if (playlist && !error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedVideoToPlaylist" object:playlist];
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
            [[delegate getNavigationController] pushViewController:playlistController onCompletion:nil context:nil animated:YES];
            break;
        }
            
        case tWatchLater:
        {
            if ([button isSelected]) {
                [button setSelected:FALSE];
                [delegate.contentManager removeVideoFromWatchLater:video callback:^(BOOL removed, NSError *error) {
                    if (removed && !error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"removedVideoFromWatchLater" object:video];
                    } else {
                        [button setSelected:TRUE];
                    }
                }];
                
            } else {
                [button setSelected:TRUE];
                [delegate.contentManager addVideoToWatchLater:video callback:^(GDataEntryYouTubePlaylist *tmp_video, NSError *error) {
                    if (tmp_video && !error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedVideoToWatchLater" object:tmp_video];
                    } else {
                        [button setSelected:FALSE];
                    }
                }];
            }
            break;
        }
            
        case tFavorites:
        {
            if ([button isSelected]) {
                [button setSelected:FALSE];
                [delegate.contentManager removeVideoFromFavorites:video callback:^(BOOL removed, NSError *error) {
                    if (removed && !error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"removedVideoFromFavorites" object:video];
                    } else {
                        [button setSelected:TRUE];
                    }
                }];
                
            } else {
                [button setSelected:TRUE];
                [delegate.contentManager addVideoToFavorites:video callback:^(GDataEntryYouTubeFavorite *tmp_video, NSError *error) {
                    if (tmp_video && !error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedVideoToFavorites" object:tmp_video];
                    } else {
                        [button setSelected:FALSE];
                    }
                }];
            }
            break;
        }
            
        case tComments:
        {
            [[delegate getNavigationController] pushViewController:[[APPCommentsListViewController alloc] initWithVideo:video] onCompletion:nil context:nil animated:YES];
            break;
        }
            
        case tLike:
        {
            if (![button isSelected]) {
                [button setSelected:TRUE];
                [button setTag:tLikeLike];
                [delegate.contentManager likeVideo:video callback:^(GDataEntryYouTubeVideo *tmp_video, NSError *error) {
                    if (tmp_video && !error) {
                        delegate.video = tmp_video;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"likedVideo" object:tmp_video];
                    } else {
                        [button setSelected:FALSE];
                        [button setTag:tLike];
                    }
                }];
            }
            break;
        }
            
        case tLikeLike:
        {
            if ([button isSelected]) {
                [button setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
                [button setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
                [button setTag:tLikeDislike];
                [delegate.contentManager dislikeVideo:video callback:^(GDataEntryYouTubeVideo *tmp_video, NSError *error) {
                    if (tmp_video && !error) {
                        delegate.video = tmp_video;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"dislikedVideo" object:tmp_video];
                    } else {
                        [button setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
                        [button setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
                        [button setTag:tLikeLike];
                    }
                }];
            }
            break;
        }
            
        case tLikeDislike:
        {
            if ([button isSelected]) {
                [button setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateSelected];
                [button setImage:[UIImage imageNamed:@"video_detail_heart_normal_down"] forState:UIControlStateHighlighted];
                [button setTag:tLikeLike];
                [delegate.contentManager likeVideo:video callback:^(GDataEntryYouTubeVideo *tmp_video, NSError *error) {
                    if (tmp_video && !error) {
                        delegate.video = tmp_video;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"likedVideo" object:tmp_video];
                    } else {
                        [button setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateSelected];
                        [button setImage:[UIImage imageNamed:@"video_detail_heart_other_down"] forState:UIControlStateHighlighted];
                        [button setTag:tLikeDislike];
                    }
                }];
            }
            break;
        }
    }
}

+ (void)removeVideo:(GDataEntryYouTubePlaylist*)video fromPlaylist:(GDataEntryYouTubePlaylistLink*)playlist delegate:(id<Base, HasTableView, PlaylistDependenceDelegate>)delegate;
{
    [delegate.contentManager removeVideoFromPlaylist:video callback:^(BOOL removed, NSError *error) {
        if (removed && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removedVideoFromPlaylist" object:playlist];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove video from playlist. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

+ (void)removeVideoFromFavorites:favorite delegate:(id<Base, HasTableView, VideoDependenceDelegate>)delegate
{
    [delegate.contentManager removeVideoFromFavorites:favorite callback:^(BOOL deleted, NSError *error) {
        if (deleted && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removedVideoFromFavorites" object:favorite];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove favorite. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

+ (void)deleteMyVideo:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate
{
    [delegate.contentManager deleteMyVideo:video callback:^(BOOL deleted, NSError *error) {
        if (deleted && !error) {
            [delegate toInitialState];            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deletedMyVideo" object:video];

        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to delete video. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

+ (void)removeVideoFromWatchLater:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate
{
    [delegate.contentManager removeVideoFromWatchLater:video callback:^(BOOL deleted, NSError *error) {
        if (deleted && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removedVideoFromWatchLater" object:video];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to delete video. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

+ (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath delegate:(id<Base, HasTableView>)delegate
{
    APPVideoCell *selectedCell = (APPVideoCell*) [delegate.tableView cellForRowAtIndexPath:indexPath];
    if (![selectedCell isOpened])
        return indexPath;
    else
        return nil;
}

+ (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath delegate:(id<Base, HasTableView>)delegate
{
    if (delegate.isInFullscreenMode)
    {
        APPVideoDetailViewController *detailController = [[APPVideoDetailViewController alloc] initWithVideo:[[delegate currentCustomFeed] objectAtIndex:[indexPath row]]];
        [[delegate getNavigationController] pushViewController:detailController onCompletion:nil context:nil animated:YES];
    }
}

@end
