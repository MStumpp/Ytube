//
//  APPSliderViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPIndexViewController.h"
#import "Helpers.h"

#define tSearchButton 01
#define tRecentlyFeaturedButton 02
#define tMostPopularButton 03
#define ttopRatedButton 04
#define ttopFavoritesButton 05

#define tFavoritesButton 11
#define tPlaylistsButton 13
#define tHistoryButton 14
#define tWatchLaterButton 15
#define tMyVideosButton 16
#define tSignOutButton 17

#define tMoveToLeft 1
#define tMoveToCenter 2
#define tMoveToRight 3

@interface APPSliderViewController : UIViewController <UINavigationControllerDelegate, TVNavigationControllerDelegate, UITableViewMaskViewDelegate>

- (void)moveToLeft:(void (^)(void))callback;
- (void)moveToCenter:(void (^)(void))callback;
- (void)moveToRight:(void (^)(void))callback;

@property (strong, nonatomic) APPIndexViewController *controller;

- (void)mask:(BOOL)mask onCompletion:(void (^)(void))callback;
- (BOOL)isMasked;

@end
