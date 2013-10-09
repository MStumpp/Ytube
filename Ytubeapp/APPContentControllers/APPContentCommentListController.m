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
@end

@implementation APPContentCommentListController
@synthesize video;

-(id)initWithVideo:(GDataEntryYouTubeVideo*)v
{
    self = [self init];
    if (self) {
        self.video = v;
        [self.dataCache clearData:tCommentsAll];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_comments"];

        [[self configureDefaultState] onViewState:tDidLoadViewState do:^(State *this, State *other){
            [self.userImageView setImage:nil];
            [[APPUserManager classInstance] imageForCurrentUserWithCallback:^(UIImage *image) {
                if (image)
                    [self.userImageView setImage:image];
            }];
        }];
        
        [self.dataCache configureReloadDataForKey:tCommentsAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
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
        
        [self.dataCache configureLoadMoreDataForKey:tCommentsAll withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];

    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 8.0, 48.0, 48.0)];
    [subtopbarContainer addSubview:self.userImageView];

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(85.0, 8.0, 220.0, 100.0)];
    [self.textField setFont:[UIFont fontWithName: @"Nexa Light" size:12]];
    [self.textField setTextColor:[UIColor blackColor]];
    self.textField.clipsToBounds = YES;
    self.textField.layer.cornerRadius = 10.0f;
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    [self.textField setDelegate:self];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [subtopbarContainer addSubview:self.textField];

    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(14.0, 79.0, 64, 30)];
    [cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateHighlighted];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateSelected];
    [subtopbarContainer addSubview:cancelButton];

    [self.tableViewHeaderFormView2 setHeaderView:subtopbarContainer];
    
    [self.tableView addDefaultShowMode:tCommentsAll];
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
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
            }
        } animated:YES];
    }
    return YES;
}

-(void)cancelButtonPress:(id)sender
{
    if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        self.textField.text = @"";
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden) {
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
            }
        } animated:YES];
    }
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPCommentCell"];
    if (cell == nil)
        cell = [[APPCommentCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPCommentCell"];

    [cell setComment:(GDataEntryYouTubeComment*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]]];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.openCell && [self.openCell row] == [indexPath row]) {
//        return self.rowOpenHeight;
//    } else {
//        return 88.0;
//    }
//}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (![[APPUserManager classInstance] isUserSignedIn])
        return FALSE;

    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment*) [[self.dataCache getData:tCommentsAll] objectAtIndex:[indexPath row]];
    return [APPContent isUser:[[APPUserManager classInstance] getUserProfile] authorOf:comment];
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPQueryHelper deleteComment:comment FromVideo:self.video];
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if ([self inState:tPassiveState]) return;

    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];

//    APPCommentCell *cell = (APPCommentCell *) [tableView cellForRowAtIndexPath:indexPath];
//
//    if (self.openCell) {
//        NSMutableArray *reloadArray = [NSMutableArray arrayWithObject:self.openCell];
//        NSIndexPath *tmp_row_open = self.openCell;
//        self.openCell = nil;
//
//        if ([tmp_row_open row] != [indexPath row]) {
//            self.openCell = indexPath;
//            [reloadArray addObject:self.openCell];
//            self.rowOpenHeight = [cell cellHeightFullComment];
//        }
//
//        [self.tableView reloadRowsAtIndexPaths:reloadArray withRowAnimation:UITableViewRowAnimationFade];
//
//    } else {
//
//        self.openCell = indexPath;
//        self.rowOpenHeight = [cell cellHeightFullComment];
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.openCell] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
}

-(void)processEvent:(NSNotification*)notification
{
    NSDictionary *context = [(NSDictionary*)[notification userInfo] objectForKey:@"context"];
    if ([context objectForKey:@"video"] == self.video)
        if (![(NSDictionary*)[notification userInfo] objectForKey:@"error"])
            [self.tableView clearViewAndReloadAll];
}

@end