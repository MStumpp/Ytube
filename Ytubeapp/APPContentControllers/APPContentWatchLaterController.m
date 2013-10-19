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
        
        [self setDefaultState:tWatchLaterAll];
        
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventWillRemoveVideoFromWatchLater object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromWatchLater object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.tableView addDefaultShowMode:tWatchLaterAll];
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo*) [[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.dataCache getData:mode] removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        NSMutableDictionary *info = [NSMutableDictionary new];
        [info setValue:video forKey:@"video"];
        [[NSNotificationCenter defaultCenter] postNotificationName:eventWillRemoveVideoFromWatchLater object:self userInfo:info];
        [APPQueryHelper removeVideoFromWatchLater:video];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    if ([[notification name] isEqualToString:eventWillRemoveVideoFromWatchLater]) {
        GDataEntryYouTubeVideo *video = [(NSDictionary*)[notification userInfo] objectForKey:@"video"];
        [[self.dataCache getData:tWatchLaterAll] removeObject:video];
        
        NSString *videoID = [APPContent videoID:video];
        [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[APPContent videoID:[obj video]] isEqualToString:videoID]) {
                // ugly, but doesn't work without the delay for some unknown reason
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:obj]] withRowAnimation:UITableViewRowAnimationTop];
                });
            }
        }];
        
    } else if ([[notification name] isEqualToString:eventAddedVideoToWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to watch later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        [self.tableView clearViewAndReload];
    
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromWatchLater]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove video from watch later."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self.tableView clearViewAndReload];
        }
    }
}

-(void)userSignedOut:(NSNotification*)notification
{
    [super userSignedOut:notification];
    [self.tableView clearView];
}

@end