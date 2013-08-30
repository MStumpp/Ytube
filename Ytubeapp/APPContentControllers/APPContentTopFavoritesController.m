//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopFavoritesController.h"

@implementation APPContentTopFavoritesController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_top_favorites"];

        // configure tToday as default state
        [self setDefaultState:[NSString stringWithFormat:@"%d", tToday]];

        // configure tWeek state
        [[self configureState:[NSString stringWithFormat:@"%d", tWeek]] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tWeek];
        }];

        // configure tMonth state
        [[self configureState:[NSString stringWithFormat:@"%d", tMonth]] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tMonth];
        }];

        // configure tAll state
        [[self configureState:[NSString stringWithFormat:@"%d", tAll]] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tAll];
        }];
    }
    return self;
}

-(void)loadView
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
            buttonToday, [NSNumber numberWithInt:tToday],
            buttonWeek, [NSNumber numberWithInt:tWeek],
            buttonMonth, [NSNumber numberWithInt:tMonth],
            buttonAll, [NSNumber numberWithInt:tAll],
            nil];

    [self.tableView addDefaultShowMode:tToday];
    [self.tableView addShowMode:tWeek];
    [self.tableView addShowMode:tMonth];
    [self.tableView addShowMode:tAll];
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper topFavoriteVideosOnShowMode:mode withPrio:p delegate:tableView];
}

-(Query*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)p
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:p delegate:tableView];
}

@end