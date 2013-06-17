//
//  APPCommentLogicHelper.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 16.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPCommentLogicHelper.h"
#import "APPCommentCell.h"

@implementation APPCommentLogicHelper

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath delegate:(id<Base, HasTableView>)delegate
{
    APPCommentCell *cell = [delegate.tableView dequeueReusableCellWithIdentifier:@"APPCommentCell"];
    if (cell == nil) {
        cell = [[APPCommentCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPCommentCell"];
    }
    
    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment *) [[delegate currentCustomFeed] objectAtIndex:[indexPath row]];
    
    cell.name = [(GDataPerson*)[[comment authors] objectAtIndex:0] name];
    cell.comment = [[comment content] stringValue];
    if (delegate.openCell && [delegate.openCell row] == [indexPath row])
        cell.showFullComment = TRUE;
    else
        cell.showFullComment = FALSE;
    
    cell.date = [[comment updatedDate] date];
    
    [delegate.contentManager imageForComment:comment callback:^(UIImage *image) {
        if (image)
            cell.profilePic = image;
    }];
    
    return cell;
}

+ (void)addComment:(GDataEntryYouTubeComment*)comment ToVideo:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate
{
    [delegate.contentManager addComment:comment ToVideo:video callback:^(GDataEntryYouTubeComment *comment, NSError *error) {
        if (comment && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addedCommentToVideo" object:video];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"We could not add your comment. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

+ (void)deleteComment:(GDataEntryYouTubeComment*)comment FromVideo:(GDataEntryYouTubeVideo*)video delegate:(id<Base, HasTableView>)delegate
{
    [delegate.contentManager deleteComment:comment callback:^(BOOL deleted, NSError *error) {
        if (deleted && !error) {
            [delegate toInitialState];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deletedCommentFromVideo" object:video];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to delete your comment. Please try again later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

@end
