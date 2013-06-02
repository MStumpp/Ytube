//
//  APPMostViewedViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 30.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPMostViewedViewController.h"

@implementation APPMostViewedViewController

- (id)init
{
    self = [super init];
    if (self) {        
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_most_popular"];
        
        /*[self.contentManager imageLoader:@"http://cs.anu.edu.au/student/comp6700/lectures/block-2/a_pie.jpg" callback:^(UIImage *image) {
            NSLog(@"1");
        }];
        [self.contentManager imageLoader:@"http://0.gravatar.com/avatar/ad516503a11cd5ca435acc9bb6523536?s=40" callback:^(UIImage *image) {
            NSLog(@"2");
        }];*/
        
        [self addShowMode:tAll];
        [self addShowMode:tToday];
        
        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            [self resetAllShowModes];
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tToday];
        }];
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishView:) name:@"removedVideoFromWatchLater" object:nil];
        
        [self toInitialState];
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
}

- (APPQueryTicket*)reloadDataConcreteOfShowMode:(int)mode withPrio:(int)prio
{
    return [self.contentManager mostPopular:mode prio:prio context:[NSNumber numberWithInt:mode] delegate:self didFinishSelector:@selector(reloadDataResponse:)];
}

- (APPQueryTicket*)loadMoreDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    if ([self currentFeedForShowMode:mode])
        return [self.contentManager loadMoreData:[self currentFeedForShowMode:mode] prio:prio context:[NSNumber numberWithInt:mode] delegate:self didFinishSelector:@selector(loadMoreDataResponse:)];
    return nil;
}

- (void)didFinishView:(NSNotification*)notification
{
    if ([notification name] == @"removedVideoFromWatchLater")
    {
        if (self.showMode == tAll) {
            [self.tableViewMaskView maskOnCompletion:^(BOOL isMasked) {
                if (isMasked) {
                    [self reloadDataForShowMode:tAll withPrio:tHighest];
                }
            }];
        } else {
            [self reloadDataForShowMode:tAll withPrio:tDefault];
        }
        
        if (self.showMode == tToday) {
            [self.tableViewMaskView maskOnCompletion:^(BOOL isMasked) {
                if (isMasked) {
                    [self reloadDataForShowMode:tToday withPrio:tHighest];
                }
            }];
        } else {
            [self reloadDataForShowMode:tToday withPrio:tDefault];
        }
    }
}

@end
