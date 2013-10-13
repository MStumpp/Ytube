//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopRatedController.h"
#import "APPVideoTopRated.h"
#import "APPFetchMoreQuery.h"

#define tTopRatedToday @"top_rated_today"
#define tTopRatedWeek @"top_rated_week"
#define tTopRatedMonth @"top_rated_month"
#define tTopRatedAll @"top_rated_all"

@implementation APPContentTopRatedController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_top_rated"];

        self.keyConvert = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tToday], tTopRatedToday,
                           [NSNumber numberWithInt:tWeek], tTopRatedWeek,
                           [NSNumber numberWithInt:tMonth], tTopRatedMonth,
                           [NSNumber numberWithInt:tAll], tTopRatedAll, nil];
        
        // configure tToday as default state
        [self setDefaultState:tTopRatedToday];

        // configure tWeek state
        [[self configureState:tTopRatedWeek] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tTopRatedWeek];
        }];

        // configure tMonth state
        [[self configureState:tTopRatedMonth] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tTopRatedMonth];
        }];

        // configure tAll state
        [[self configureState:tTopRatedAll] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tTopRatedAll];
        }];
        
        [self.dataCache configureReloadDataForKeys:@[tTopRatedToday, tTopRatedWeek, tTopRatedMonth, tTopRatedAll] withHandler:^(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            queryHandler(key, [[APPVideoTopRated instanceWithQueue:[[[APPGlobals classInstance] getGlobalForKey:@"queuemanager"] queueWithName:@"queue"]]
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
        
        [self.dataCache configureLoadMoreDataForKeys:@[tTopRatedToday, tTopRatedWeek, tTopRatedMonth, tTopRatedAll] withHandler:^(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler) {
            
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

    UIButton *buttonToday = [[UIButton alloc] initWithFrame:CGRectMake(16, 6, 66, 30)];
    [buttonToday addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonToday setImage:[UIImage imageNamed:@"sub_top_bar_button_today_up_4"] forState:UIControlStateNormal];
    [buttonToday setImage:[UIImage imageNamed:@"sub_top_bar_button_today_down_4"] forState:UIControlStateHighlighted];
    [buttonToday setImage:[UIImage imageNamed:@"sub_top_bar_button_today_down_4"] forState:UIControlStateSelected];
    [buttonToday setTag:tToday];
    [subtopbarContainer addSubview:buttonToday];

    UIButton *buttonWeek = [[UIButton alloc] initWithFrame:CGRectMake(90, 6, 66, 30)];
    [buttonWeek addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonWeek setImage:[UIImage imageNamed:@"sub_top_bar_button_week_up_4"] forState:UIControlStateNormal];
    [buttonWeek setImage:[UIImage imageNamed:@"sub_top_bar_button_week_down_4"] forState:UIControlStateHighlighted];
    [buttonWeek setImage:[UIImage imageNamed:@"sub_top_bar_button_week_down_4"] forState:UIControlStateSelected];
    [buttonWeek setTag:tWeek];
    [subtopbarContainer addSubview:buttonWeek];

    UIButton *buttonMonth = [[UIButton alloc] initWithFrame:CGRectMake(163, 6, 66, 30)];
    [buttonMonth addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMonth setImage:[UIImage imageNamed:@"sub_top_bar_button_month_up_4"] forState:UIControlStateNormal];
    [buttonMonth setImage:[UIImage imageNamed:@"sub_top_bar_button_month_down_4"] forState:UIControlStateHighlighted];
    [buttonMonth setImage:[UIImage imageNamed:@"sub_top_bar_button_month_down_4"] forState:UIControlStateSelected];
    [buttonMonth setTag:tMonth];
    [subtopbarContainer addSubview:buttonMonth];

    UIButton *buttonAll = [[UIButton alloc] initWithFrame:CGRectMake(237, 6, 66, 30)];
    [buttonAll addTarget:self action:@selector(subtopbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonAll setImage:[UIImage imageNamed:@"sub_top_bar_button_all_up_4"] forState:UIControlStateNormal];
    [buttonAll setImage:[UIImage imageNamed:@"sub_top_bar_button_all_down_4"] forState:UIControlStateHighlighted];
    [buttonAll setImage:[UIImage imageNamed:@"sub_top_bar_button_all_down_4"] forState:UIControlStateSelected];
    [buttonAll setTag:tAll];
    [subtopbarContainer addSubview:buttonAll];

    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer];

    self.buttons = [[NSDictionary alloc] initWithObjectsAndKeys:
            buttonToday, tTopRatedToday,
            buttonWeek, tTopRatedWeek,
            buttonMonth, tTopRatedMonth,
            buttonAll, tTopRatedAll,
            nil];

    [self.tableView addDefaultShowMode:tTopRatedToday];
    [self.tableView addShowMode:tTopRatedWeek];
    [self.tableView addShowMode:tTopRatedMonth];
    [self.tableView addShowMode:tTopRatedAll];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        if (oldContentOffset.y < newContentOffset.y && [self.tableViewHeaderFormView isHeaderShown] && newContentOffset.y > downAtTopDistance) {
            [self.tableViewHeaderFormView hideOnCompletion:nil animated:NO];
        } else if (oldContentOffset.y > newContentOffset.y && ![self.tableViewHeaderFormView isHeaderShown] && (downAtTopOnly ? (newContentOffset.y < downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - downAtTopDistance)))) {
            [self.tableViewHeaderFormView showOnCompletion:nil animated:NO];
        }
        
        //if((newVal.y >= 0.0) && (newVal.y <= self.tableView.contentSize.height)) {
        //}
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end