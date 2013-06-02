//
//  APPSliderViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.08.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPSliderViewController.h"

#import "APPSearchViewController.h"
#import "APPFeaturedViewController.h"
#import "APPMostViewedViewController.h"
#import "APPTopFavoritesViewController.h"
#import "APPTopRatedViewController.h"

#import "APPFavoritesViewController.h"
#import "APPPlaylistsViewController.h"
#import "APPHistoryViewController.h"
#import "APPWatchLaterViewController.h"
#import "APPMyVideosViewController.h"

#import "TVNavigationController.h"

#import "MBProgressHUD.h"

@interface APPSliderViewController ()

@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UIControl *leftImageView;
@property (strong, nonatomic) UIControl *rightImageView;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) TVNavigationController *navController;

@property (strong, nonatomic) UITableViewMaskView *maskView;

@property (strong, nonatomic) UIImageView *leftShadow;
@property (strong, nonatomic) UIImageView *rightShadow;

@property NSInteger currentFocus;
@property NSInteger selectedButton;
@property NSInteger selectedController;

@property NSDictionary *buttons;
@property NSDictionary *controllers;

@end

@implementation APPSliderViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.controllers = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[APPSearchViewController alloc] init], [NSNumber numberWithInt:tSearchButton],
                            [[APPFeaturedViewController alloc] init], [NSNumber numberWithInt:tRecentlyFeaturedButton],
                            [[APPMostViewedViewController alloc] init], [NSNumber numberWithInt:tMostPopularButton],
                            [[APPTopRatedViewController alloc] init], [NSNumber numberWithInt:ttopRatedButton],
                            [[APPTopFavoritesViewController alloc] init], [NSNumber numberWithInt:ttopFavoritesButton],
                            [[APPFeaturedViewController alloc] init], [NSNumber numberWithInt:tRecentlyFeaturedButton],
                            [[APPFavoritesViewController alloc] init], [NSNumber numberWithInt:tFavoritesButton],
                            [[APPPlaylistsViewController alloc] init], [NSNumber numberWithInt:tPlaylistsButton],
                            [[APPHistoryViewController alloc] init], [NSNumber numberWithInt:tHistoryButton],
                            [[APPWatchLaterViewController alloc] init], [NSNumber numberWithInt:tWatchLaterButton],
                            [[APPMyVideosViewController alloc] init], [NSNumber numberWithInt:tMyVideosButton],
                            nil];
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    
    // view structure
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(-82, 0, self.view.frame.size.width+82+82, self.view.frame.size.height)];
    [self.view addSubview:self.mainView];
    
    self.leftImageView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 82, self.view.frame.size.height)];
    [self.leftImageView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_left"]]];
    [self.mainView addSubview:self.leftImageView];
    
    // set up left buttons
    
    UIButton *buttonSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 82, 60) ];
    [buttonSearch addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSearch setImage:[UIImage imageNamed:@"nav_left_search_up"] forState:UIControlStateNormal];
    [buttonSearch setImage:[UIImage imageNamed:@"nav_left_search_down"] forState:UIControlStateHighlighted];
    [buttonSearch setImage:[UIImage imageNamed:@"nav_left_search_down"] forState:UIControlStateSelected];
    [buttonSearch setTag:tSearchButton];
    [self.leftImageView addSubview:buttonSearch];
    
    UIButton *buttonMostPopular = [[UIButton alloc] initWithFrame:CGRectMake(0, 60, 82, 60)];
    [buttonMostPopular addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMostPopular setImage:[UIImage imageNamed:@"nav_left_most_popular_up"] forState:UIControlStateNormal];
    [buttonMostPopular setImage:[UIImage imageNamed:@"nav_left_most_popular_down"] forState:UIControlStateHighlighted];
    [buttonMostPopular setImage:[UIImage imageNamed:@"nav_left_most_popular_down"] forState:UIControlStateSelected];
    [buttonMostPopular setTag:tMostPopularButton];
    [self.leftImageView addSubview:buttonMostPopular];
    
    UIButton *buttonTopRated = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, 82, 60)];
    [buttonTopRated addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTopRated setImage:[UIImage imageNamed:@"nav_left_top_rated_up"] forState:UIControlStateNormal];
    [buttonTopRated setImage:[UIImage imageNamed:@"nav_left_top_rated_down"] forState:UIControlStateHighlighted];
    [buttonTopRated setImage:[UIImage imageNamed:@"nav_left_top_rated_down"] forState:UIControlStateSelected];
    [buttonTopRated setTag:ttopRatedButton];
    [self.leftImageView addSubview:buttonTopRated];
    
    UIButton *buttonTopFavorites = [[UIButton alloc] initWithFrame:CGRectMake(0, 180, 82, 60)];
    [buttonTopFavorites addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTopFavorites setImage:[UIImage imageNamed:@"nav_left_top_favorites_up"] forState:UIControlStateNormal];
    [buttonTopFavorites setImage:[UIImage imageNamed:@"nav_left_top_favorites_down"] forState:UIControlStateHighlighted];
    [buttonTopFavorites setImage:[UIImage imageNamed:@"nav_left_top_favorites_down"] forState:UIControlStateSelected];
    [buttonTopFavorites setTag:ttopFavoritesButton];
    [self.leftImageView addSubview:buttonTopFavorites];

    UIButton *buttonRecentlyFeatured = [[UIButton alloc] initWithFrame:CGRectMake(0, 240, 82, 60)];
    [buttonRecentlyFeatured addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecentlyFeatured setImage:[UIImage imageNamed:@"nav_left_featured_up"] forState:UIControlStateNormal];
    [buttonRecentlyFeatured setImage:[UIImage imageNamed:@"nav_left_featured_down"] forState:UIControlStateHighlighted];
    [buttonRecentlyFeatured setImage:[UIImage imageNamed:@"nav_left_featured_down"] forState:UIControlStateSelected];
    [buttonRecentlyFeatured setTag:tRecentlyFeaturedButton];
    [self.leftImageView addSubview:buttonRecentlyFeatured];
        
    self.rightImageView = [[UIControl alloc] initWithFrame:CGRectMake(402, 0, 82, self.view.frame.size.height)];
    [self.rightImageView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_right"]]];
    [self.mainView addSubview:self.rightImageView];
    
    // set up right buttons
    
    UIButton *buttonFavorites = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 82, 60) ];
    [buttonFavorites addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonFavorites setImage:[UIImage imageNamed:@"nav_right_favorites_up"] forState:UIControlStateNormal];
    [buttonFavorites setImage:[UIImage imageNamed:@"nav_right_favorites_down"] forState:UIControlStateHighlighted];
    [buttonFavorites setImage:[UIImage imageNamed:@"nav_right_favorites_down"] forState:UIControlStateSelected];
    [buttonFavorites setTag:tFavoritesButton];
    [self.rightImageView addSubview:buttonFavorites];

    UIButton *buttonPlaylists = [[UIButton alloc] initWithFrame:CGRectMake(0, 60, 82, 60)];
    [buttonPlaylists addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPlaylists setImage:[UIImage imageNamed:@"nav_right_playlists_up"] forState:UIControlStateNormal];
    [buttonPlaylists setImage:[UIImage imageNamed:@"nav_right_playlists_down"] forState:UIControlStateHighlighted];
    [buttonPlaylists setImage:[UIImage imageNamed:@"nav_right_playlists_down"] forState:UIControlStateSelected];
    [buttonPlaylists setTag:tPlaylistsButton];
    [self.rightImageView addSubview:buttonPlaylists];
    
    UIButton *buttonHistory = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, 82, 60)];
    [buttonHistory addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonHistory setImage:[UIImage imageNamed:@"nav_right_history_up"] forState:UIControlStateNormal];
    [buttonHistory setImage:[UIImage imageNamed:@"nav_right_history_down"] forState:UIControlStateHighlighted];
    [buttonHistory setImage:[UIImage imageNamed:@"nav_right_history_down"] forState:UIControlStateSelected];
    [buttonHistory setTag:tHistoryButton];
    [self.rightImageView addSubview:buttonHistory];
        
    UIButton *buttonMyVideos = [[UIButton alloc] initWithFrame:CGRectMake(0, 180, 82, 60)];
    [buttonMyVideos addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMyVideos setImage:[UIImage imageNamed:@"nav_right_my_videos_up"] forState:UIControlStateNormal];
    [buttonMyVideos setImage:[UIImage imageNamed:@"nav_right_my_videos_down"] forState:UIControlStateHighlighted];
    [buttonMyVideos setImage:[UIImage imageNamed:@"nav_right_my_videos_down"] forState:UIControlStateSelected];
    [buttonMyVideos setTag:tMyVideosButton];
    [self.rightImageView addSubview:buttonMyVideos];
    
    UIButton *buttonWatchLater = [[UIButton alloc] initWithFrame:CGRectMake(0, 240, 82, 60)];
    [buttonWatchLater addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonWatchLater setImage:[UIImage imageNamed:@"nav_right_watch_later_up"] forState:UIControlStateNormal];
    [buttonWatchLater setImage:[UIImage imageNamed:@"nav_right_watch_later_down"] forState:UIControlStateHighlighted];
    [buttonWatchLater setImage:[UIImage imageNamed:@"nav_right_watch_later_down"] forState:UIControlStateSelected];
    [buttonWatchLater setTag:tWatchLaterButton];
    [self.rightImageView addSubview:buttonWatchLater];
    
    UIButton *buttonSignOut = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 82, 60)];
    [buttonSignOut addTarget:self action:@selector(navbarButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSignOut setImage:[UIImage imageNamed:@"nav_right_sign_out_up"] forState:UIControlStateNormal];
    [buttonSignOut setImage:[UIImage imageNamed:@"nav_right_sign_out_down"] forState:UIControlStateHighlighted];
    [buttonSignOut setImage:[UIImage imageNamed:@"nav_right_sign_out_down"] forState:UIControlStateSelected];
    [buttonSignOut setTag:tSignOutButton];
    [self.rightImageView addSubview:buttonSignOut];
    
    self.buttons = [[NSDictionary alloc] initWithObjectsAndKeys:
                    buttonSearch, [NSNumber numberWithInt:tSearchButton],
                    buttonRecentlyFeatured, [NSNumber numberWithInt:tRecentlyFeaturedButton],
                    buttonMostPopular, [NSNumber numberWithInt:tMostPopularButton],
                    buttonTopRated, [NSNumber numberWithInt:ttopRatedButton],
                    buttonTopFavorites, [NSNumber numberWithInt:ttopFavoritesButton],
                    buttonFavorites, [NSNumber numberWithInt:tFavoritesButton],
                    buttonPlaylists, [NSNumber numberWithInt:tPlaylistsButton],
                    buttonHistory, [NSNumber numberWithInt:tHistoryButton],
                    buttonWatchLater, [NSNumber numberWithInt:tWatchLaterButton],
                    buttonMyVideos, [NSNumber numberWithInt:tMyVideosButton],
                    buttonSignOut, [NSNumber numberWithInt:tSignOutButton],
                    nil];
        
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(82, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.mainView addSubview:self.centerView];
    self.navController = [[TVNavigationController alloc] init];
    self.navController._delegate_ = self;
    self.navController.view.frame = CGRectOffset(self.navController.view.frame, 0.0, -20.0);
    [self.centerView addSubview:self.navController.view];
    
    // shadows
    self.rightShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_shadow_right"]];
    [self.rightShadow setHidden:YES];
    [self.view addSubview:self.rightShadow];
    
    self.leftShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_shadow_left"]];
    [self.leftShadow setHidden:YES];
    [self.view addSubview:self.leftShadow];
    
    self.maskView = [[UITableViewMaskView alloc] initWithRootView:self.view customMaskView:nil delegate:self];
    UIView *progressView = [[UIView alloc] init];
    [MBProgressHUD showHUDAddedTo:progressView animated:YES];
    [self.maskView setCustomMaskView:progressView];
    self.view = self.maskView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    frame.origin.y = frame.origin.y - 20.0;
    self.view.frame = frame;
    
    if (self.currentFocus) {
        [self show:self.currentFocus];
    } else {
        [self show:tMostPopularButton];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.buttons = nil;
}

- (void)show:(int)tag
{
    if (![[APPContentManager classInstance] isUserSignedIn] && !(tag == tMostPopularButton || tag == tRecentlyFeaturedButton || tag == tSearchButton || tag == ttopFavoritesButton || tag == ttopRatedButton)) {
        self.currentFocus = tMostPopularButton;
    } else {
        self.currentFocus = tag;
    }
        
    [self selectButton:self.currentFocus];
    [self selectTableView:self.currentFocus];
}

- (void)navbarButtonPress:(UIButton*)sender
{
    int currentFocusWas = self.currentFocus;
    self.currentFocus = [sender tag];
    [self selectButton:self.currentFocus];
    [self animateMoveToCenter:^{
        
        [self.controller unselectButtons];
        
        switch (self.currentFocus)
        {
            case tSignOutButton:
            {
                [self mask:YES onCompletion:^{
                    [self.controller signOutOnCompletion:^(BOOL isSignedOut) {
                        [self mask:NO onCompletion:^{
                            if (isSignedOut) {
                                [self show:currentFocusWas];
                            } else {
                                [[[UIAlertView alloc] initWithTitle:@"Something went wrong..."
                                                            message:[NSString stringWithFormat:@"Unable to sign you out. Please try again later."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil] show];
                            }
                        }];
                    }];
                }];
                break;
            }
                
            default:
            {
                [self selectTableView:self.currentFocus];
                break;
            }
        }
    }];
}

- (void)selectButton:(NSInteger)tag
{
    if (!self.selectedButton || (self.selectedButton && self.selectedButton != tag)) {
        // deselect currently selected button
        if (self.selectedButton)
            [[self.buttons objectForKey:[NSNumber numberWithInt:self.selectedButton]] setSelected:NO];
        
        self.selectedButton = tag;
        
        // select button
        [[self.buttons objectForKey:[NSNumber numberWithInt:self.selectedButton]] setSelected:YES];
    }
}

- (void)selectTableView:(NSInteger)tag
{
    if (self.selectedController && self.selectedController == tag) {
        if ([[self.navController viewControllers] count] > 1)
            [self.navController popToRootViewControllerAnimated:YES];
        //[(APPBaseListViewController*) [self.navController topViewController] toInitialState];
        
    } else {
        self.selectedController = tag;
        [self.navController setRootViewController:[self.controllers objectForKey:[NSNumber numberWithInt:self.selectedController]]];
    }
    [(APPBaseListViewController*) [self.navController topViewController] didFullScreenModeInitially:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{    
    // prefer topbarImage over topbarTitle, so check topbarImage first
    if ([(APPBaseListViewController*)viewController topbarImage]) {
        [self.controller setToolbarBackgroundImage:[(APPBaseListViewController*)viewController topbarImage]];
        
    } else if ([(APPBaseListViewController*)viewController topbarTitle]) {
        [self.controller setToolbarTitle:[(APPBaseListViewController*)viewController topbarTitle]];
    }
}

// called when login screen pushed (in APPIndexViewController) on top of current APPBaseListViewController

- (void)willBePushed:(void (^)(void))callback controller:(UIViewController *)controller context:(id)context
{
    if ([self isCentered]) {
        APPBaseListViewController *currentController = (APPBaseListViewController*) [self.navController topViewController];
        if ([currentController respondsToSelector:@selector(willBePushed:controller:context:)])
        {
            [currentController willBePushed:^{
                [self mask:YES onCompletion:^{
                    if (callback)
                        callback();
                }];
            } controller:controller context:context];
        
        } else {
            [self mask:YES onCompletion:^{
                if (callback)
                    callback();
            }];
        }
        
    } else {
        if (callback)
            callback();
    }
}

- (void)didFullScreenAfterPop:(void (^)(void))callback controller:(UIViewController *)controller context:(id)context
{
    int sliderMode = tMoveToLeft;
    if (context && [context isKindOfClass:[NSNumber class]])
        sliderMode = [context intValue];
    
    // only call didFullScreenAfterPop if slider is at center position and won't be sliding to the left/right position afterwards
    if ([self isCentered] && sliderMode != tMoveToLeft && sliderMode != tMoveToRight) {
        APPBaseListViewController *currentController = (APPBaseListViewController*) [self.navController topViewController];
        if ([currentController respondsToSelector:@selector(didFullScreenAfterPop:controller:context:)])
        {
            [self mask:NO onCompletion:^{
                [currentController didFullScreenAfterPop:^{
                    if (callback)
                        callback();
                } controller:controller context:context];
            }];
        } else {
            [self mask:NO onCompletion:^{
                if (callback)
                    callback();
            }];
        }
        
    } else {
        [self mask:NO onCompletion:^{
            if (callback)
                callback();
        }];
    }
}

- (void)moveToLeft:(void (^)(void))callback
{
    if ([self.navController topViewController] && [self isCentered]) {
        [(APPBaseListViewController*) [self.navController topViewController] willSplitScreenMode:^{
            [self animateMoveToLeft:^{
                if (callback)
                    callback();
            }];
        }];
    } else {
        [self animateMoveToLeft:^{
            if (callback)
                callback();
        }];
    }    
}

- (void)moveToCenter:(void (^)(void))callback
{
    if ([self.navController topViewController] && ![self isCentered]) {
        [self animateMoveToCenter:^{
            [(APPBaseListViewController*) [self.navController topViewController] didFullScreenModeAfterSplitScreen:^{
                if (callback)
                    callback();
            }];
        }];
    } else {
        [self animateMoveToCenter:^{
            if (callback)
                callback();
        }];
    }
}

- (void)moveToRight:(void (^)(void))callback
{
    if ([self.navController topViewController] && [self isCentered]) {
        [(APPBaseListViewController*) [self.navController topViewController] willSplitScreenMode:^{
            [self animateMoveToRight:^{
                if (callback)
                    callback();
            }];
        }];
    } else {
        [self animateMoveToRight:^{
            if (callback)
                callback();
        }];
    }
}

// private helper methods

- (void)animateMoveToLeft:(void (^)(void))callback
{
    if (self.mainView.frame.origin.x == -82 || self.mainView.frame.origin.x == -164)
    {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             CGRect mainViewFrame = self.mainView.frame;
                             mainViewFrame.origin.x = 0;
                             self.mainView.frame = mainViewFrame;
                         }
                         completion:^(BOOL finished){
                             [self.rightShadow setHidden:NO];
                             if (callback)
                                 callback();
                         }];
    } else
    {
        if (callback)
            callback();
    }
}

- (void)animateMoveToCenter:(void (^)(void))callback
{
    if (self.mainView.frame.origin.x == 0 || self.mainView.frame.origin.x == -164)
    {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             CGRect mainViewFrame = self.mainView.frame;
                             mainViewFrame.origin.x = -82;
                             self.mainView.frame = mainViewFrame;
                         }
                         completion:^(BOOL finished){
                             [self.rightShadow setHidden:YES];
                             [self.leftShadow setHidden:YES];
                             if (callback)
                                 callback();
                         }];
    } else
    {
        if (callback)
            callback();
    }
}

- (void)animateMoveToRight:(void (^)(void))callback
{
    if (self.mainView.frame.origin.x == 0 || self.mainView.frame.origin.x == -82)
    {
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             CGRect mainViewFrame = self.mainView.frame;
                             mainViewFrame.origin.x = -164;
                             self.mainView.frame = mainViewFrame;
                         }
                         completion:^(BOOL finished){
                             [self.leftShadow setHidden:NO];
                             if (callback)
                                 callback();
                         }];
    } else
    {
        if (callback)
            callback();
    }
}

- (BOOL)isCentered
{
    return (self.mainView.frame.origin.x == -82);
}

- (void)mask:(BOOL)mask onCompletion:(void (^)(void))callback
{
    if (mask)
        [self.maskView maskOnCompletion:^(BOOL isMasked) {
            if (isMasked && callback)
                callback();
        }];
    else
        [self.maskView unmaskOnCompletion:^(BOOL isUnmasked) {
            if (isUnmasked && callback)
                callback();
        }];
}

- (BOOL)isMasked
{
    return self.maskView.isMasked;
}

@end
