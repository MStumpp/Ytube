//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentMostViewedVideoController.h"
#import "APPVideoMostViewed.h"
#import "APPFetchMoreQuery.h"

#define tMostViewedToday @"most_viewed_today"
#define tMostViewedAll @"most_viewed_all"

@implementation APPContentMostViewedVideoController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_most_popular"];

        self.keyConvert = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tToday], tMostViewedToday,
                           [NSNumber numberWithInt:tAll], tMostViewedAll, nil];
        
        // configure tToday as default state
        [self setDefaultState:tMostViewedToday];

        // configure tAll state
        [[self configureState:tMostViewedAll] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tMostViewedAll];
        }];
        
        [self.dataCache configureReloadDataForKeys:@[tMostViewedToday, tMostViewedAll] withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPVideoMostViewed instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
                    execute:[NSMutableDictionary dictionaryWithObjectsAndKeys:[self keyToNumber:key], @"mode", nil]
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
        
        [self.dataCache configureLoadMoreDataForKeys:@[tMostViewedToday, tMostViewedAll] withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];

    UIButton *buttonToday = [[UIButton alloc] initWithFrame:CGRectMake(16, 6, 132, 30)];
    [buttonToday addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonToday setImage:[UIImage imageNamed:@"sub_top_bar_button_today_up_2"] forState:UIControlStateNormal];
    [buttonToday setImage:[UIImage imageNamed:@"sub_top_bar_button_today_down_2"] forState:UIControlStateHighlighted];
    [buttonToday setImage:[UIImage imageNamed:@"sub_top_bar_button_today_down_2"] forState:UIControlStateSelected];
    [buttonToday setTag:tToday];
    [subtopbarContainer addSubview:buttonToday];

    UIButton *buttonAll = [[UIButton alloc] initWithFrame:CGRectMake(172, 6, 132, 30)];
    [buttonAll addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonAll setImage:[UIImage imageNamed:@"sub_top_bar_button_all_up_2"] forState:UIControlStateNormal];
    [buttonAll setImage:[UIImage imageNamed:@"sub_top_bar_button_all_down_2"] forState:UIControlStateHighlighted];
    [buttonAll setImage:[UIImage imageNamed:@"sub_top_bar_button_all_down_2"] forState:UIControlStateSelected];
    [buttonAll setTag:tAll];
    [subtopbarContainer addSubview:buttonAll];

    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer];

    self.buttons = [[NSDictionary alloc] initWithObjectsAndKeys:
             buttonToday, tMostViewedToday,
             buttonAll, tMostViewedAll,
             nil];

    [self.tableView addDefaultShowMode:tMostViewedToday];
    [self.tableView addShowMode:tMostViewedAll];
}

@end