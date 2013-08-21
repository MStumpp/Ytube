//
//  APPSliderViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPIndexViewController.h"
#import "UITableViewMaskView.h"
#import "SmartNavigationController.h"

// context
#define tNone 01
#define tSearch 02
#define tRecentlyFeatured 03
#define tMostPopular 04
#define ttopRated 05
#define ttopFavorites 06
#define tFavorites 11
#define tPlaylists 12
#define tHistory 13
#define tWatchLater 14
#define tMyVideos 15
#define tSignOut 16

#define tMoveToLeft 1
#define tMoveToCenter 2
#define tMoveToRight 3

@interface APPSliderViewController : UIViewController <UINavigationControllerDelegate, SmartNavigationControllerDelegate, UITableViewMaskViewDelegate>
@property APPIndexViewController *controller;
// move this controller to the left
- (void)moveToLeft:(void (^)(void))callback;
// move this controller to the center
- (void)moveToCenter:(void (^)(void))callback;
// move this controller to the right
- (void)moveToRight:(void (^)(void))callback;
@end
