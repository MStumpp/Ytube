//
// Created by Matthias Stumpp on 19.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPPlaylistListController.h"
#import "APPContentPlaylistVideosContoller.h"
#import "APPTextCell.h"
#import "APPTextLogicHelper.h"

@implementation APPPlaylistListController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_playlists"];

        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishView:) name:@"addedVideoToWatchLater" object:nil];
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tDefault];
        }];

        [self toInitialState];
    }
    return self;
}

-(void)loadView
{
    [super loadView];

    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_common_field_small"]]];

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 9.0, 210.0, 26.0)];
    [self.textField setTextColor:[UIColor blackColor]];
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    [self.textField setDelegate:self];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    self.textField.placeholder = @"Enter Playlist Name";
    [subtopbarContainer addSubview:self.textField];

    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(242, 6, 71, 30)];
    [cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateHighlighted];
    [cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateSelected];
    [subtopbarContainer addSubview:cancelButton];

    [self.tableViewHeaderFormView2 setHeaderView:subtopbarContainer];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.tableViewHeaderFormView2 isHeaderShown]) {
        [self.textField resignFirstResponder];
        GDataEntryYouTubePlaylistLink *playlist = [[GDataEntryYouTubePlaylistLink alloc] init];
        [playlist setTitleWithString:self.textField.text];
        id this = self;
        [self.contentManager addPlaylist:playlist callback:^(GDataEntryYouTubePlaylistLink *playlist, NSError *error) {
            if (playlist && !error) {
                [this toInitialState];

            } else {
                [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                            message:[NSString stringWithFormat:@"We could not add your playlist. Please try again later."]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }];
        self.textField.text = @"";
        [self.tableViewHeaderFormView2 hideOnCompletion:^(BOOL isHidden) {
            if (isHidden)
                [self.tableViewHeaderFormView1 showOnCompletion:nil animated:YES];
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

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    APPTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPTextCell"];
    if (cell == nil) {
        cell = [[APPTextCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPTextCell"];
    }

    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink *) [[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]]];
    cell.text = [[playlist title] stringValue];
    cell.description = [[playlist summary] stringValue];

    [delegate.contentManager imageForPlaylist:playlist callback:^(UIImage *image) {
        if (image)
            cell.textPic = image;
    }];

    return cell;
}

- (void)tableViewSwipeViewDidSwipeLeft:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTableCell *cell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isClosed] && self.tmpEditingCell && [self.tmpEditingCell row] == [indexPath row]) {
        self.tmpEditingCell = nil;
        [self.tableView setEditing:NO animated:YES];

    } else {
        [super tableViewSwipeViewDidSwipeLeft:view rowAtIndexPath:indexPath];
    }
}

- (void)tableViewSwipeViewDidSwipeRight:(UITableView *)view rowAtIndexPath:(NSIndexPath *)indexPath
{
    APPTableCell *cell = (APPTableCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView isEditing] && [cell isClosed] && !self.tmpEditingCell) {
        self.tmpEditingCell = indexPath;
        [self.tableView setEditing:YES animated:YES];

    } else if ([self.tableView isEditing] && [cell isClosed] && self.tmpEditingCell && [self.tmpEditingCell row] != [indexPath row]) {
        self.tmpEditingCell = indexPath;
        [self.tableView setEditing:NO animated:YES];
        [self.tableView setEditing:YES animated:YES];

    } else {
        [super tableViewSwipeViewDidSwipeRight:view rowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tmpEditingCell) {
        if ([self.tmpEditingCell row] == [indexPath row])
            return TRUE;
        else
            return FALSE;
    } else {
        return TRUE;
    }
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle didSelectEntry:(GDataEntryBase*)entry
{
    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink *)entry;
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPTextLogicHelper deletePlaylist:playlist delegate:self];
}

-(void)tableView:(UITableView *)tableView didSelectEntry:(GDataEntryBase*)entry
{
    if (!self.isDefaultMode)
        return;

    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink *)entry;

    if (self.callback)
        self.callback(playlist);
    else
        [self.navigationController pushViewController:[[APPContentPlaylistVideosContoller alloc] initWithPlaylist:playlist] animated:YES];
}

@end