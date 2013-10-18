//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentHistoryController.h"
#import "APPVideoWatchHistory.h"
#import "APPFetchMoreQuery.h"

#define tWatchHistoryAll @"watch_history_all"

@implementation APPContentHistoryController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_history"];
        
        [[self configureState:tUserSignOutState] onViewState:tDidInitViewState do:^(State *this, State *other){
            [self.tableView clearView];
        }];

        [[self configureState:tUserSignInState] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toDefaultShowModeForce];
        }];
        
        [self.dataCache configureReloadDataForKey:tWatchHistoryAll withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPVideoWatchHistory instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
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
        
        [self.dataCache configureLoadMoreDataForKey:tWatchHistoryAll withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEvent:) name:eventVideoWatched object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.tableView addDefaultShowMode:tWatchHistoryAll];
}

-(void)processEvent:(NSNotification*)notification
{
    if (![(NSDictionary*)[notification userInfo] objectForKey:@"error"])
        [self.tableView clearViewAndReloadAll];
}

@end