//
// Created by Matthias Stumpp on 20.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentCommentListController.h"
#import "APPVideoAddComment.h"
#import "APPCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "APPVideoComments.h"
#import "APPFetchMoreQuery.h"

#define tCommentsAll @"comments_all"

@interface APPContentCommentListController ()
@property UITextField *textField;
@property UIImageView *userImageView;
@property NSInteger rowOpenHeight;
@property NSIndexPath *openCommentCell;
@property NSIndexPath *wasOpenCommentCell;
@property NSString *commentsId;
@end

@implementation APPContentCommentListController
@synthesize video;

-(id)initWithVideo:(GDataEntryYouTubeVideo*)v
{
    self = [super init];
    if (self) {
        self.video = v;
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_comments"];

        self.commentsId = [NSString stringWithFormat:@"%@_%@", tCommentsAll, [APPContent videoID:self.video]];
        
        [[self configureDefaultState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.userImageView setImage:nil];
            [[APPUserManager classInstance] imageForCurrentUserWithCallback:^(UIImage *image) {
                if (image)
                    [self.userImageView setImage:image];
            }];
        }];
        
        [[self configureState:tPassiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // close open comment cell
            if (self.openCommentCell) {
                self.wasOpenCommentCell = self.openCommentCell;
                [self tapCell:self.openCommentCell];
            } else {
                self.wasOpenCommentCell = nil;
            }
        }];
        
        [[self configureState:tActiveState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            // open comment cell if one was open previously
            if (self.wasOpenCommentCell) {
                [self tapCell:self.wasOpenCommentCell];
            }
        }];
        
        [self.dataCache configureReloadDataForKey:self.commentsId withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPVideoComments instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.video, @"video", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [self.dataCache configureLoadMoreDataForKey:self.commentsId withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
            queryHandler(key, [[APPFetchMoreQuery instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:[NSDictionary dictionaryWithObjectsAndKeys:previous, @"feed", nil]
                               context:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil]
                               onStateChange:^(NSString *state, id data, NSError *error, id context) {
                                   if ([state isEqual:tFinished]) {
                                       responseHandler([(NSDictionary*)context objectForKey:@"key"],
                                                       [(NSDictionary*)context objectForKey:@"context"],
                                                       data,
                                                       error);
                                   }
                               }]
                         );
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedCommentToVideo object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventDeletedCommentFromVideo object:nil];
    }
    return self;
}

-(void)loadView
{
    [super loadView];

    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 120.0)];

    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 8.0, 48.0, 48.0)];
    [subtopbarContainer addSubview:self.userImageView];

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(85.0, 8.0, 220.0, 100.0)];
    [self.textField setFont:[UIFont fontWithName: @"Nexa Light" size:12]];
    [self.textField setTextColor:[UIColor whiteColor]];
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.textField.clipsToBounds = YES;
    self.textField.layer.cornerRadius = 5.0f;
    [self.textField setBackgroundColor:[UIColor darkGrayColor]];
    [self.textField setDelegate:self];
    [self.textField setReturnKeyType:UIReturnKeySend];
    [subtopbarContainer addSubview:self.textField];

    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(14.0, 79.0, 64, 30)];
    [cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateHighlighted];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateSelected];
    [subtopbarContainer addSubview:cancelButton];

    [self.tableViewHeaderFormView2 setHeaderView:subtopbarContainer];
    
    [self.tableView addDefaultShowMode:self.commentsId];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        [self.textField resignFirstResponder];
        GDataEntryYouTubeComment *comment = [[GDataEntryYouTubeComment alloc] init];
        [comment setContentWithString:self.textField.text];
        [APPQueryHelper addComment:comment ToVideo:self.video];
        self.textField.text = @"";
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden) {
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:NO];
            }
        } animated:NO];
    }
    return YES;
}

-(void)cancelButtonPress:(id)sender
{
    if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        self.textField.text = @"";
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden) {
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:NO];
            }
        } animated:NO];
    }
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPCommentCell"];
    if (cell == nil)
        cell = [[APPCommentCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPCommentCell"];

    [cell setComment:(GDataEntryYouTubeComment*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]]];
    if ([indexPath isEqual:self.openCommentCell])
        [cell setOpen:TRUE];
    return cell;
}

-(CGFloat)tableView:(UITableView*)tableView forMode:(NSString*)mode heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.openCommentCell && [self.openCommentCell row] == [indexPath row]) {
        return self.rowOpenHeight;
    } else {
        return 88.0;
    }
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if ([self inState:tPassiveState]) return;
    [self tapCell:indexPath];
}

-(void)tapCell:(NSIndexPath*)indexPath;
{
    APPCommentCell *cell = (APPCommentCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell) {
        return;
    }
    
    if (self.openCommentCell) {
        NSMutableArray *reloadArray = [NSMutableArray arrayWithObject:self.openCommentCell];
        NSIndexPath *tmp_row_open = self.openCommentCell;
        self.openCommentCell = nil;
        
        if ([tmp_row_open row] != [indexPath row]) {
            self.openCommentCell = indexPath;
            [reloadArray addObject:self.openCommentCell];
            self.rowOpenHeight = [cell cellHeightFullComment];
        }
        
        [self.tableView reloadRowsAtIndexPaths:reloadArray withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        self.openCommentCell = indexPath;
        self.rowOpenHeight = [cell cellHeightFullComment];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.openCommentCell] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self inState:tPassiveState]) return FALSE;
    if (![[APPUserManager classInstance] isUserSignedIn]) return FALSE;
    if (![self.tableView isEditing]) return FALSE;
    
    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment*) [[self.dataCache getData:tCommentsAll] objectAtIndex:[indexPath row]];
    return [APPContent isUser:[[APPUserManager classInstance] getUserProfile] authorOf:comment];
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.dataCache getData:mode] removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [APPQueryHelper deleteComment:comment FromVideo:self.video];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    NSDictionary *context = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if ([context objectForKey:@"video"] != self.video)
        return;
    
    if ([[notification name] isEqualToString:eventAddedCommentToVideo]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add comment to video."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        [self.tableView clearViewAndReloadAll];
        
    } else if ([[notification name] isEqualToString:eventDeletedCommentFromVideo]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove comment from video."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self.tableView clearViewAndReloadAll];
        }
    }
}

@end