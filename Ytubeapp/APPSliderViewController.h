//
//  APPSliderViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPIndexViewController.h"

// left menus
#define tSearchButton 01
#define tRecentlyFeaturedButton 02
#define tMostPopularButton 03
#define ttopRatedButton 04
#define ttopFavoritesButton 05

// right menus
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
@property (strong, nonatomic) APPIndexViewController *controller;
// move this controller to the left
- (void)moveToLeft:(void (^)(void))callback;
// move this controller to the center
- (void)moveToCenter:(void (^)(void))callback;
// move this controller to the right
- (void)moveToRight:(void (^)(void))callback;
// call this method with true to mask this controller, to unmask call it with false
- (void)mask:(BOOL)mask onCompletion:(void (^)(void))callback;
// true if contoller is masked, false otherwise
- (BOOL)isMasked;
@end
