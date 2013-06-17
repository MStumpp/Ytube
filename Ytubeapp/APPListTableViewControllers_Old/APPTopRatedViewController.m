//
//  APPTopRatedViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 12.09.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPTopRatedViewController.h"

@interface APPTopRatedViewController()
@property (nonatomic, retain) GDataFeedBase *feedToday;
@property (nonatomic, retain) GDataFeedBase *feedWeek;
@property (nonatomic, retain) GDataFeedBase *feedMonth;
@property (nonatomic, retain) GDataFeedBase *feedAll;
@property (nonatomic, retain) NSMutableArray *customFeedToday;
@property (nonatomic, retain) NSMutableArray *customFeedWeek;
@property (nonatomic, retain) NSMutableArray *customFeedMonth;
@property (nonatomic, retain) NSMutableArray *customFeedAll;
@end

@implementation APPTopRatedViewController

- (id)init
{
    self = [super init];
    if (self) {        
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_top_rated"];
        
        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.feedToday = nil;
            self.feedWeek = nil;
            self.feedMonth = nil;
            self.feedAll = nil;
            self.customFeedToday = nil;
            self.customFeedWeek = nil;
            self.customFeedMonth = nil;
            self.customFeedAll = nil;
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tToday];
        }];
        
        [self toInitialState];
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
                    buttonToday, [NSNumber numberWithInt:tToday],
                    buttonWeek, [NSNumber numberWithInt:tWeek],
                    buttonMonth, [NSNumber numberWithInt:tMonth],
                    buttonAll, [NSNumber numberWithInt:tAll],
                    nil];
}

- (void)reloadData
{
    if (self.showMode)
        [self.contentManager topRated:self.showMode delegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
}

-(void)loadMoreData
{
    if ([self currentFeed])
        [self.contentManager loadMoreData:[self currentFeed] delegate:self didFinishSelector:@selector(loadMoreDataResponse:finishedWithFeed:error:)];
}

-(GDataFeedBase*)currentFeed:(GDataFeedBase*)feed
{
    switch (self.showMode)
    {
        case tToday:
            if (feed)
                self.feedToday = feed;
            return self.feedToday;
        case tWeek:
            if (feed)
                self.feedWeek = feed;
            return self.feedWeek;
        case tMonth:
            if (feed)
                self.feedMonth = feed;
            return self.feedMonth;
        case tAll:
            if (feed)
                self.feedAll = feed;
            return self.feedAll;
        default:
            return nil;
    }
}

-(NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed;
{
    switch (self.showMode)
    {
        case tToday:
            if (feed)
                self.customFeedToday = feed;
            return self.customFeedToday;
        case tWeek:
            if (feed)
                self.customFeedWeek = feed;
            return self.customFeedWeek;
        case tMonth:
            if (feed)
                self.customFeedMonth = feed;
            return self.customFeedMonth;
        case tAll:
            if (feed)
                self.customFeedAll = feed;
            return self.customFeedAll;
        default:
            return nil;
    }
}

@end
