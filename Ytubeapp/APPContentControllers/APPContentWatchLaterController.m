//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentWatchLaterController.h"
#import "APPWatchLater.h"
#import "APPFetchMoreQuery.h"

#define tWatchLaterAll @"watch_later_all"

@implementation APPContentWatchLaterController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_watch_later"];
        
        [[self configureState:tUserSignOutState] onViewState:tDidInitViewState do:^(State *this, State *other){
            NSLog(@"[self.tableView clearView %@]", self.class);
            [self.tableView clearView];
        }];
        
        [[self configureState:tUserSignInState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            NSLog(@"[self.tableView toDefaultShowModeForce] %@", self.class);
            [self.tableView toDefaultShowModeForce];
        }];
        
        [self.dataCache configureReloadDataForKey:tWatchLaterAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPWatchLater instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
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
        
        [self.dataCache configureLoadMoreDataForKey:tWatchLaterAll withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeWatchLater:) name:eventWillRemoveVideoFromWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromWatchLater object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.tableView addDefaultShowMode:tWatchLaterAll];
}

-(void)removeWatchLater:(NSNotification*)notification
{
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo*) [[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.dataCache getData:mode] removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [APPQueryHelper removeVideoFromWatchLater:video];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    if ([[notification name] isEqualToString:eventAddedVideoToWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to watch later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        [self.tableView clearViewAndReloadAll];
        
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove video from watch later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self.tableView clearViewAndReloadAll];
        }
    }
}

@end