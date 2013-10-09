//
// Created by Matthias Stumpp on 19.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentPlaylistListController.h"
#import "APPContentPlaylistVideosController.h"
#import "APPPlaylistCell.h"
#import "APPPlaylists.h"
#import "APPFetchMoreQuery.h"

#define tPlaylistsAll @"playlists_all"

@interface APPContentPlaylistListController ()
@property UITextField *textField;
@end

@implementation APPContentPlaylistListController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_playlists"];
        
        [self.dataCache configureReloadDataForKey:tPlaylistsAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPPlaylists instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                               execute:NULL
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
        
        [self.dataCache configureLoadMoreDataForKey:tPlaylistsAll withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedPlaylist object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventDeletedPlaylist object:nil];
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
    
    [self.tableView addDefaultShowMode:tPlaylistsAll];
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

-(APPTableCell*)tableView:(UITableView*)tableView forMode:(NSString*)mode cellForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    APPPlaylistCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"APPPlaylistCell"];
    if (cell == nil)
        cell = [[APPPlaylistCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"APPPlaylistCell"];

    [cell setPlaylist:(GDataEntryYouTubePlaylistLink*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]]];
    return cell;
}

#pragma mark -
#pragma mark Table View Data Source Methods
// TODO: Remove table cell locally
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink *)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
        [APPQueryHelper deletePlaylist:playlist];
}

-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
{
    NSLog(@"didSelectRowAtIndexPath 1");
    
    if ([self inState:tPassiveState]) return;
    
    NSLog(@"didSelectRowAtIndexPath 2");

    GDataEntryYouTubePlaylistLink *playlist = (GDataEntryYouTubePlaylistLink*)[[self.dataCache getData:mode] objectAtIndex:[indexPath row]];

    NSLog(@"didSelectRowAtIndexPath 3");
    
    if (self.afterSelect) {
        NSLog(@"didSelectRowAtIndexPath 4");
        [self.navigationController popViewControllerAnimated:YES];
        self.afterSelect(playlist);
    } else {
        NSLog(@"didSelectRowAtIndexPath 5");
        [self.navigationController pushViewController:[[APPContentPlaylistVideosController alloc] initWithPlaylist:playlist] animated:YES];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    if (![(NSDictionary*)[notification object] objectForKey:@"error"])
        [self.tableView clearViewAndReloadAll];
}

@end