//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentFavoritesController.h"
#import "APPFavorites.h"
#import "APPFetchMoreQuery.h"

#define tFavoritesAll @"favorites_all"

@implementation APPContentFavoritesController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_favorites"];
        
        [self.dataCache configureReloadDataForKey:tFavoritesAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPFavorites instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
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
        
        [self.dataCache configureLoadMoreDataForKey:tFavoritesAll withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventAddedVideoToFavorites object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventRemovedVideoFromFavorites object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.tableView addDefaultShowMode:tFavoritesAll];
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(void)tableView:(UITableView*)tableView forMode:(NSString*)mode commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath;
{
    GDataEntryYouTubeFavorite *favorite = (GDataEntryYouTubeFavorite*) [[self.dataCache getData:mode] objectAtIndex:[indexPath row]];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.dataCache getData:mode] removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [APPQueryHelper removeVideoFromFavorites:favorite];
    }
}

-(void)processEvent:(NSNotification*)notification
{
    if ([[notification name] isEqualToString:eventAddedVideoToFavorites]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to add video to favorites."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        [self.tableView clearViewAndReloadAll];
        
    } else if ([[notification name] isEqualToString:eventRemovedVideoFromFavorites]) {
        if ([(NSDictionary*)[notification userInfo] objectForKey:@"error"]) {
            [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                        message:[NSString stringWithFormat:@"Unable to remove video from favorites."]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self.tableView clearViewAndReloadAll];
        }
    }
}

@end