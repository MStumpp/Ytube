//
// Created by Matthias Stumpp on 19.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentPlaylistListController.h"
#import "APPContentPlaylistVideosController.h"
#import "APPPlaylistCell.h"

@interface APPContentPlaylistListController ()
@property (nonatomic, strong) UITextField *textField;
@end

@implementation APPContentPlaylistListController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_playlists"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedPlaylist object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventDeletedPlaylist object:nil];

        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
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
        [APPQueryHelper addPlaylist:playlist];
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

-(QueryTicket*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    return [APPQueryHelper playlistsOnShowMode:mode withPrio:prio delegate:tableView];
}

-(QueryTicket*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)prio
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:prio delegate:tableView];
}

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(int)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    APPPlaylistCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPPlaylistCell"];
    if (cell == nil)
        cell = [[APPPlaylistCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPPlaylistCell"];

    [cell setPlaylist:(GDataEntryYouTubePlaylistLink *)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]]];
    return cell;
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView*)tableView forMode:(int)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink *)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPQueryHelper deletePlaylist:playlist];
}

-(void)tableView:(UITableView*)tableView forMode:(int)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if (self.isDefaultMode)
        return;

    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink*)[[self.tableView currentCustomFeed] objectAtIndex:[indexPath row]];

    if (self.afterSelect) {
        [self.navigationController popViewControllerAnimated:YES];
        self.afterSelect(playlist);
    } else {
        [self.navigationController pushViewController:[[APPContentPlaylistVideosController alloc] initWithPlaylist:playlist] animated:YES];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    if (![(NSDictionary*)[notification object] objectForKey:@"error"])
        [self.tableView reloadShowMode];
}

@end