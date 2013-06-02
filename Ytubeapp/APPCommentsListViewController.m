//
//  APPCommentsListViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 24.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPCommentsListViewController.h"
#import "APPCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "APPCommentLogicHelper.h"

@interface APPCommentsListViewController ()
@property (nonatomic, retain) UIImageView *userImageView;
@property (nonatomic, retain) GDataFeedBase *feedDefault;
@property (nonatomic, retain) NSMutableArray *customFeedDefault;
@property NSInteger rowOpenHeight;
@end

@implementation APPCommentsListViewController

@synthesize video;

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_comments"];
        
        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.feedDefault = nil;
            self.customFeedDefault = nil;
        }] onViewState:tDidLoad do:^() {
            [self.userImageView setImage:nil];
            [this toShowMode:tDefault];
            [[APPContentManager classInstance] imageForCurrentUserWithCallback:^(UIImage *image) {
                if (image)
                    [self.userImageView setImage:image];
            }];
        }];
                
        [self toInitialState];
    }
    return self;
}

- (id)initWithVideo:(GDataEntryYouTubeVideo *)vid
{
    self = [self init];
    if (self) {
        self.video = vid;
    }
    return self;
}

- (void)loadView
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
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        [self.textField resignFirstResponder];
        GDataEntryYouTubeComment *comment = [[GDataEntryYouTubeComment alloc] init];
        [comment setContentWithString:self.textField.text];
        [APPCommentLogicHelper addComment:comment ToVideo:self.video delegate:self];
        self.textField.text = @"";
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden) {
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
            }
        } animated:YES];
    }
    return YES;
}

- (void)reloadData
{
    if (self.video)
        [self.contentManager comments:(GDataEntryYouTubeVideo*)self.video delegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
}

- (void)loadMoreData
{
    if ([self currentFeed])
        [self.contentManager loadMoreData:[self currentFeed] delegate:self didFinishSelector:@selector(loadMoreDataResponse:finishedWithFeed:error:)];
}

- (GDataFeedBase*)currentFeed:(GDataFeedBase*)feed
{
    switch (self.showMode)
    {
        case tDefault:
            if (feed)
                self.feedDefault = feed;
            return self.feedDefault;
        default:
            return nil;
    }
}

- (NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed;
{
    switch (self.showMode)
    {
        case tDefault:
            if (feed)
                self.customFeedDefault = feed;
            return self.customFeedDefault;
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.openCell && [self.openCell row] == [indexPath row]) {
        return self.rowOpenHeight;
    } else {
        return 88.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [APPCommentLogicHelper tableView:tableView cellForRowAtIndexPath:indexPath delegate:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (!self.userProfile)
        return FALSE;
    
    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
    
    return [self.contentManager isUser:self.userProfile authorOf:comment];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger row = [indexPath row];
    //UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    GDataEntryYouTubeComment *comment = (GDataEntryYouTubeComment *) [[self currentCustomFeed] objectAtIndex:[indexPath row]];
    
    [APPCommentLogicHelper deleteComment:comment FromVideo:self.video delegate:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APPCommentCell *cell = (APPCommentCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.openCell) {
        NSMutableArray *reloadArray = [NSMutableArray arrayWithObject:self.openCell];
        NSIndexPath *tmp_row_open = self.openCell;
        self.openCell = nil;

        if ([tmp_row_open row] != [indexPath row]) {
            self.openCell = indexPath;
            [reloadArray addObject:self.openCell];
            self.rowOpenHeight = [cell cellHeightFullComment];
        }

        [self.tableView reloadRowsAtIndexPaths:reloadArray withRowAnimation:UITableViewRowAnimationFade];
                
    } else {
        
        self.openCell = indexPath;
        self.rowOpenHeight = [cell cellHeightFullComment];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.openCell] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end