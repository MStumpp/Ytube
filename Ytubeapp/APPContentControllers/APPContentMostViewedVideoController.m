//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentMostViewedVideoController.h"

@implementation APPContentMostViewedVideoController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_most_popular"];

        // configure tToday as default state
        [self setDefaultState:[NSString stringWithFormat:@"%d", tToday]];

        // configure tAll state
        [[self configureState:[NSString stringWithFormat:@"%d", tAll]] onViewState:tDidAppearViewState do:^(State *this, State *other){
            [self.tableView toShowMode:tAll];
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
             buttonToday, [NSNumber numberWithInt:tToday],
             buttonAll, [NSNumber numberWithInt:tAll],
             nil];

    [self.tableView addDefaultShowMode:tToday];
    [self.tableView addShowMode:tAll];
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper mostViewedVideosOnShowMode:mode withPrio:p delegate:tableView];
}

-(Query*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)p
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:p delegate:tableView];
}

@end